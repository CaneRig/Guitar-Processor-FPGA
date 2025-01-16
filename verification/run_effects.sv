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
    logic[31: 0] sample_out; 
    
    initial begin
        clk = '0;
        rst = '0;
        valid = '1;
        done = '0;
        gain_value = 10'b100000;

        read_wave("sample.wav", '0, res, data, rate, depth, channel_count, sample_count); 
        $display("File read");
        #1;
        clk = '1;
        #1;
        clk = '0;

        foreach (data[i]) begin
            #1;
            sample_in = data[i] / 2 ** 4;
            ttmp = data[i];
            clk = '1; 
            #1;
            //ttmp = {ttmp[7: 0], ttmp[15: 8]};
            clk = '0; 
        end
        done = '1;
    end


    effects_pipline i_eff_pipe(
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .gain_value(gain_value),
        .sample_in(sample_in),
        .sample_out(sample_out)
    );

    sample_t output_data[];
    int read_sample_count = 500000;

    initial begin
        $dumpfile("run-effect.vcd");
        $dumpvars;
        output_data = new[read_sample_count];
        tfile = $fopen("data.txt", "w");


        #2;

        for (int i=0; i<read_sample_count; ++i) begin
            #2;
            output_data[i] = sample_out * 16;

            // $display(" -- %d\t->\t%d", sshort'(sample_in), sample_out);
        end

        #1;
        write_wave("data.wav", 16, rate, output_data);
        $display("File wrote");

        $finish;
    end 

endmodule