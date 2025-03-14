//----------------------------------------------------------------------------
// Testbench based on https://github.com/yuri-panchul/systemverilog-homework/
//----------------------------------------------------------------------------

`include "util.svh"

module testbench;
    localparam SLEN = 16;
    //--------------------------------------------------------------------------
    // Signals to drive Device Under Test - DUT

    logic               clk;
    logic               rst;

    // logic               arg_vld;
    logic  [SLEN - 1:0] sample_in;

    // wire                res_vld;
    wire   [SLEN - 1:0] sample_out;

    //--------------------------------------------------------------------------
    // Instantiating DUT

    effects_pipeline dut (
        .clk(clk), // slow !?!
        .rst('0),
        .valid('1),
		.i_par_gain(10'd10<<3),
          
		.i_sample(sample_in),
		.o_sample(sample_out)
    );

    //--------------------------------------------------------------------------
    // Driving clk

    initial
    begin
        clk = '1;

        forever
        begin
            # 5 clk = ~ clk;
        end
    end

    //------------------------------------------------------------------------
    // Reset

    task reset ();

        rst <= 'x;
        repeat (3) @ (posedge clk);
        rst <= '1;
        repeat (3) @ (posedge clk);
        rst <= '0;

    endtask

    //--------------------------------------------------------------------------
    // Driving stimulus

    localparam TIMEOUT = 5000;

    task run ();

        $display ("--------------------------------------------------");
        $display ("Running %m");

        // Init and reset

        // arg_vld <= '0;
        reset ();

        // Direct testing - a single test

        sample_in       <=  (SLEN)'(12);
        // arg_vld <= '1;

        @ (posedge clk);
        // arg_vld <= '0;

        // while (~ res_vld)
        //     @ (posedge clk);

        // Direct testing - a group of tests

        for (int i = -int'(10); i < 100; i = i * 3 + 1)
        begin
            sample_in       <= (SLEN)'(i);

            // arg_vld <= '1;

            @ (posedge clk);
            // arg_vld <= '0;

            // while (~ res_vld)
                // @ (posedge clk);
        end

        // Random testing

        repeat (20)
        begin
            sample_in       <= 12'($urandom());

            // arg_vld <= '1;

            @ (posedge clk);
            // arg_vld <= '0;

            // while (~ res_vld)
                // @ (posedge clk);
        end

    endtask

    //--------------------------------------------------------------------------
    // Running testbench

    initial
    begin
        `ifdef __ICARUS__
            // Uncomment the following line
            // to generate a VCD file and analyze it using GTKwave

            $dumpvars;
        `endif

        run ();

        $finish;
    end

    //--------------------------------------------------------------------------
    // Logging

    int unsigned cycle = 0;

    always @ (posedge clk)
    begin
        $write ("%s time %7d cycle %5d", `__FILE__, $time, cycle);
        cycle <= cycle + 1'b1;

        // if (rst)
        //     $write (" rst");
        // else
        //     $write ("    ");

        // if (arg_vld)
        //     // Optionnaly change to `PF_BITS optionally
        //     $write (" arg %s %s %s", `PG_BITS (a), `PG_BITS (b), `PG_BITS (c) );
        // else
        //     $write ("                                     ");

        // if (res_vld)
        //     $write (" res %s", `PG_BITS(res) );

        /// $write("in: ");

        $display;
    end

    //--------------------------------------------------------------------------
    // Modeling and checking

    logic [SLEN - 1:0] queue [$];
    logic [SLEN - 1:0] res_expected;

    logic was_reset = 0;

    // Blocking assignments are okay in this synchronous always block, because
    // data is passed using queue and all the checks are inside that always
    // block, so no race condition is possible

    // verilator lint_off BLKSEQ

    always @ (posedge clk)
    begin
        if (rst)
        begin
            queue = {};
            was_reset = 1;
        end
        else if (was_reset)
        begin
            // if (arg_vld)
            // begin
            //     res_expected = $realtobits( $bitstoreal (b) * $bitstoreal (b) - 4 * $bitstoreal (a) * $bitstoreal (c) );

            //     queue.push_back (res_expected);
            // end

            // if (res_vld)
            // begin
            //     if (queue.size () == 0)
            //     begin
            //         $display ("FAIL %s: unexpected result %s",
            //             `__FILE__, `PG_BITS (res) );

            //         $finish;
            //     end
            //     else
            //     begin
            //         `ifdef __ICARUS__
            //             // Some version of Icarus has a bug, and this is a workaround
            //             res_expected = queue [0];
            //             queue.delete (0);
            //         `else
            //             res_expected = queue.pop_front ();
            //         `endif

            //         err_expected = is_err ( res_expected );
            //         if (err !== err_expected )
            //         begin
            //             $display ("FAIL %s: error mismatch. Expected %s, actual %s",
            //                 `__FILE__, `PB (err_expected), `PB (err) );

            //             $finish;
            //         end
            //         else if ( ( err_expected === 1'b0 ) && ( res !== res_expected ) )
            //         begin
            //             $display ("FAIL %s: res mismatch. Expected %s, actual %s",
            //                 `__FILE__, `PG_BITS (res_expected), `PG_BITS (res) );

            //             $finish;
            //         end
            //     end
            // end
        end
    end

    // verilator lint_on BLKSEQ

    //----------------------------------------------------------------------

    final
    begin
        if (queue.size () == 0)
        begin
            $display ("PASS %s", `__FILE__);
        end
        else
        begin
            $write ("FAIL %s: data is left sitting in the model queue:",
                `__FILE__);

            for (int i = 0; i < queue.size (); i ++)
                $write (" %h", queue [queue.size () - i - 1]);

            $display;
        end
    end

    //----------------------------------------------------------------------
    // Performance counters

    logic [32:0] n_cycles, arg_cnt, res_cnt;

    always @ (posedge clk)
        if (rst)
        begin
            n_cycles <= '0;
            arg_cnt  <= '0;
            res_cnt  <= '0;
        end
        else
        begin
            n_cycles <= n_cycles + 1'd1;

            // if (arg_vld)
            //     arg_cnt <= arg_cnt + 1'd1;

            // if (res_vld)
            //     res_cnt <= res_cnt + 1'd1;
        end

    //----------------------------------------------------------------------

    final
        $display ("\n\nnumber of transfers : arg %0d res %0d per %0d cycles",
            arg_cnt, res_cnt, n_cycles);

    //----------------------------------------------------------------------
    // Setting timeout against hangs

    initial
    begin
        repeat (TIMEOUT) @ (posedge clk);
        $display ("FAIL %s: timeout!", `__FILE__);
        $finish;
    end

endmodule