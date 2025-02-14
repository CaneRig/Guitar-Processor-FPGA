`include "wave.svh"
`timescale 10s/1s

typedef shortint signed sshort;

module testbench();

    sample_t data[];

    integer unsigned     rate;
    shortint unsigned    depth;
    shortint unsigned    channel_count;
    integer unsigned     sample_count;
    logic done;

    wave_read_res_t res;

    logic[10: 0] gain_value;
    logic clk;
    logic rst;
    logic valid;
    logic[11: 0] sample_in; 
    logic[15: 0] sample_out; 
    
    initial begin
        clk = '0;
        rst = '0;
        valid = '1;
        done = '0;
        gain_value = 10'b100000000;
     //    rate = 44100;

        read_wave("sample.wav", '0, res, data, rate, depth, channel_count, sample_count); 
        $display("File read");
        #1;
        clk = '1;
        #1;
        clk = '0;

        foreach (data[i]) begin
          // for (int i=0; i<2**16; ++i) begin
            #1;
            sample_in = data[i] / 2 ** 4;
          //   sample_in = i / 2 ** 4;
            clk = '1; 
            #1;
            clk = '0; 
        end
        done = '1;
    end


    effects_pipeline i_eff_pipe(
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .in_par_gain(gain_value),
        .in_sample(sample_in),
        .ou_sample(sample_out)
    );

    sample_t output_data[];
    int read_sample_count = 200000;

    initial begin
        $dumpfile("run-effect.vcd");
        $dumpvars;
        output_data = new[read_sample_count];

        #2;

        for (int i=0; i<read_sample_count; ++i) begin
            #2;
            output_data[i] = $signed(sample_out);

            // $display(" -- %d\t->\t%d", sshort'(sample_in), sample_out);
        end

        #1;
        write_wave("data.wav", 16, rate, output_data);
        $display("File wrote");

        $finish;
    end 

     int times = 0;
     initial begin

          while (!done) begin
               times+=10000 / 2;
               #10000;
               $display("TIME IS %d\t/\t%d", times, read_sample_count);
          end
     end

endmodule