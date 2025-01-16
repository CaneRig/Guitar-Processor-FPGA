`define WAVE_MAX_DEPTH 'd16
typedef enum { 
    RRES_OK = 0,
    RRES_UNKOWN_ERR = 1,
    RRES_NOT_WAVE = 2,
    RRES_PCM_STRUCTURE_ERROR = 3,
    RRES_NOT_PCM = 4,
    RRES_FILE_NOT_FOUND = 5,
    RRES_INVALID_DEPTH = 6,  // > WAVE_READER_MAX_DEPTH or % 8 != 0
    RRES_INVALID_CHANNEL = 7
} wave_read_res_t;

typedef enum { 
    WRES_OK = 0,
    WRES_FILE_NOT_FOUND = 1,
    WRES_INVALID_DEPTH = 2
} wave_write_res_t;

typedef shortint unsigned sample_t;


function integer __read_bytes(  input integer   handle,
                                input integer   byte_count,
                                input logic     big_endian = 0);
    logic[7: 0] bytev;
    integer     line;
    logic       placeholder;
    line = 0;

    for (int i=0; i < byte_count; ++i) begin
        placeholder = $fread(bytev, handle);

        if (big_endian == 1)
            line    = (line << 8) | bytev;
        else
            line    = line | (integer'(bytev) << (i*8));
    end

    return line;
endfunction

task __write_short (    input integer           fhandle,
                        input shortint unsigned value);
    $fwrite(fhandle, "%c%c", value[7 -: 8], value[15-: 8]);
endtask

task __write_int (      input integer           fhandle,
                        input integer unsigned  value);
    $fwrite(fhandle, "%c%c%c%c",    value[7 -: 8], value[15-: 8],
                                    value[23-: 8], value[31-: 8]);
endtask



task read_wave(     input string                path,
                    input shortint unsigned     channel_sel,
                    output wave_read_res_t      result,
                    output sample_t             data[], 
                    output integer unsigned     rate,
                    output shortint unsigned    depth,
                    output shortint unsigned    channel_count,
                    output integer unsigned     sample_count,
                    input  logic                verbose = '1);

    begin : fnc
        integer fhandle; 
        logic   placeholder;


        integer unsigned    chunk_id, chunk_size, format, byte_rate;
        shortint unsigned   audio_format, block_align;
        logic[7:0]          bytev;

        // reading data from file
        sample_t sample; 
        integer unsigned sample_begin;
        byte unsigned raw[]; // content of wave file data


        fhandle = $fopen(path, "rb");

        if(fhandle == 0) begin
            if (verbose)
                $display("File \"%s\" cannot be opened", path);

            result = RRES_FILE_NOT_FOUND;
            disable fnc;
        end

        chunk_id = __read_bytes(fhandle, 4, 1);
        if (chunk_id != 'h52494646) begin // RIFF
            $fclose(fhandle);

            if (verbose)
                $display("Invalid header: %h", chunk_id);

            result = RRES_NOT_WAVE;
            disable fnc;
        end

        chunk_size  = __read_bytes(fhandle, 4);

        format      = __read_bytes(fhandle, 4, 1);
        if(format != 'h57415645) begin // WAVE
            $fclose(fhandle);

            if (verbose)
                $display("File is not WAVE: %h", format);

            result = RRES_NOT_WAVE;
            disable fnc;
        end

        /////// chunk id 1
        chunk_id = __read_bytes(fhandle, 4, 1);
        if(chunk_id != 'h666d7420) begin // fmt
            $fclose(fhandle);

            if (verbose)
                $display("FMT field error: found %h expected 0x666d7420", chunk_id);

            result = RRES_PCM_STRUCTURE_ERROR;
            disable fnc;
        end

        chunk_size = __read_bytes(fhandle, 4);
        if (chunk_size != 16) begin // PCM file requirements
            $fclose(fhandle);

            if (verbose)
                $display("PCM chunk size error: found %d expected 16", chunk_size);

            result = RRES_PCM_STRUCTURE_ERROR;
            disable fnc;
        end

        audio_format = __read_bytes(fhandle, 2);
        if (audio_format != 1) begin
            $fclose(fhandle);

            if (verbose)
                $display("Format field error: found %d expected 1", audio_format);

            result = RRES_PCM_STRUCTURE_ERROR;
            disable fnc;
        end

        channel_count   =   __read_bytes(fhandle, 2);
        if (!(0 <= channel_sel && channel_sel < channel_count)) begin
            $fclose(fhandle);

            if (verbose) 
                $display("Invalid channel %d, it should be 0 <= %d < %d", channel_sel, channel_sel, channel_count);
            
            result = RRES_INVALID_CHANNEL;
            disable fnc;
        end

        rate            =   __read_bytes(fhandle, 4);

        byte_rate       =   __read_bytes(fhandle, 4);
        block_align     =   __read_bytes(fhandle, 2);

        depth           =   __read_bytes(fhandle, 2);
        if (!(depth <= `WAVE_MAX_DEPTH)) begin
            $fclose(fhandle);

            if (verbose)
                $display("Depth is too big: %d > %d", depth, `WAVE_MAX_DEPTH);

            result = RRES_INVALID_DEPTH;
            disable fnc;
        end
        if (depth % 8 != 0) begin // assuming depth is divides by 8
            $fclose(fhandle);

            if (verbose)
                $display("Depth not divising to 8 is not supported: %d %% 8 != 0", depth);

            result = RRES_INVALID_DEPTH;
            disable fnc;
        end

        // wait for data subchunk
        // data = {0x64, 0x61, 0x74, 0x61}
        chunk_id = 0;
        while (chunk_id != 'h64617461) begin
            placeholder = $fread(bytev, fhandle);
            chunk_id = (chunk_id << 8) | bytev;

            if (!(  chunk_id == 'h64        ||
                    chunk_id == 'h6461      ||
                    chunk_id == 'h646174    ||
                    chunk_id == 'h64617461  )) begin
                chunk_id = 0;
            end
        end
        chunk_size = __read_bytes(fhandle, 4);

        sample_count = chunk_size * 8 / (channel_count * depth);

        raw = new[chunk_size];
        for (int i=0; i<chunk_size; ++i) begin
            raw[i] = __read_bytes(fhandle, 1);
        end
        
        data = new[sample_count];

        sample_begin = channel_sel * depth;
        for (int s_id=0; s_id<sample_count; ++s_id) begin

            sample = 0;

            for (int i=0; i < depth/8; ++i) begin
                // sample = (sample << 8) | raw[i + sample_begin / 8];
                sample = (sample << 8) | raw[depth/8 - 1 - i + sample_begin / 8];
            end

            data[s_id] = sample;
            sample_begin += depth * channel_count;
        end
    
        result = RRES_OK;
        $fclose(fhandle);
    end
endtask


function wave_write_res_t write_wave(       input string            path,
                                            input shortint unsigned depth,
                                            input int unsigned      frequency,
                                            input sample_t          data[],
                                            input logic             verbose = '1);
    begin : fnc
        integer             fhandle;
        integer             depth_bits;
        integer unsigned    channel_count;
        integer unsigned    data_size;
        logic[31: 0]        temp;
        
        channel_count = 1;
        depth_bits    = depth / 8;
        data_size = depth * channel_count * $size(data) / 8;

        // CHECK INPUTS
        if (!(depth % 8 == 0 && depth <= `WAVE_MAX_DEPTH)) begin
            if (verbose)
                $display("Invalid depth: it should divide by 8 and 0 <= %d <= %d", depth, `WAVE_MAX_DEPTH);
            
            return WRES_INVALID_DEPTH;
        end

        // FILE
        fhandle = $fopen(path, "wb");

        if (fhandle == 0) begin
            if (verbose)
                $display("File \"%s\" cannot be opened", path);
            
            return WRES_FILE_NOT_FOUND;
        end


        $fwrite(fhandle, "RIFF");
        __write_int     (fhandle, data_size + 24);
        $fwrite(fhandle, "WAVE");


        // fmt chunk
        $fwrite         (fhandle, "fmt ");
        __write_int     (fhandle, 16); // ck size (16)
        __write_short   (fhandle, 1);  // wFormatTag = 1
        __write_short   (fhandle, channel_count);  // nChannels = 1
        
        __write_int     (fhandle, frequency);   // sample rate
        __write_int     (fhandle, frequency * depth * channel_count / 8); // data rate
        __write_short   (fhandle, depth * channel_count / 8); // data block size

        __write_short   (fhandle, depth);

        
        // data chunk
        $fwrite         (fhandle, "data");
        __write_int     (fhandle, data_size);

        for (int i=0; i < $size(data); ++i) begin
            for (int j=0; j<depth_bits; ++j) begin
                $fwrite (fhandle, "%c", (data[i] >> (8 * j)));
            end
        end

        $fclose(fhandle);
        return WRES_OK;
    end
endfunction

