//----------------------------------------------------------------------------
// Testbench based on https://github.com/yuri-panchul/systemverilog-homework/
//----------------------------------------------------------------------------

`include "util.svh"

module testbench;
    localparam SLEN = 16;
    //--------------------------------------------------------------------------
    // Signals to drive Device Under Test - DUT

    logic               clk;

    // logic               arg_vld;
    logic  [SLEN - 1:0] s2u_in;
    logic  [SLEN - 1:0] u2s_in;

    // wire                res_vld;
    wire   [SLEN - 1:0] s2u_out;
    wire   [SLEN - 1:0] u2s_out;

    wire    rst;

    //--------------------------------------------------------------------------
    // Instantiating DUT

    // [-2**15, 2**15 - 1] -> [0, 2**16 - 1]
    sign2unsign #(
            .size(SLEN)
    ) dut_s2u (
            .in(s2u_in),
            .out(s2u_out)
    );
    // [0, 2**16 - 1] -> [-2**15, 2**15 - 1]
    unsign2sign #(
            .size(SLEN)
    ) dut_u2s (
            .in(u2s_in),
            .out(u2s_out)
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

    //--------------------------------------------------------------------------
    // Driving stimulus

    localparam TIMEOUT = 500;
    shortint unsigned s2u, u2s;

    task run ();

        localparam half = 2 ** SLEN;

        $display ("--------------------------------------------------");
        $display ("Running %m");

        // Init and reset

        // Direct testing - a single test
        // arg_vld <= '1;

        @ (posedge clk);

        // Direct testing - a group of tests
        for (shortint unsigned i = 0; i < 2**10-1; i+=5000)
        begin
                        
            assign s2u_in = (SLEN)'(i); // + half
            assign u2s_in = (SLEN)'(i); // - half

            @ (posedge clk);

            assign s2u = $signed(i) + $signed(half);
            assign u2s = $signed(i) - $signed(half);

            if (u2s_out != u2s && 0==1)
                $display("u2s_out not match: %d -> %d, expected: %d", i, u2s_out, u2s);

            if (s2u_out != s2u && 0==1)
                $display("s2u_out not match: %d -> %d, expected: %d", i, s2u_out, s2u);

        end

        // Random testing

        repeat (20)
        begin
            s2u_in       <= (SLEN)'($urandom());

            @ (posedge clk);

            u2s_in <= s2u_out;

            @ (posedge clk);

            if(s2u_in != u2s_out)
                $display("Invertable test error: s2u(%d -> %d) -> u2s(%d -> %d)", s2u_in, s2u_out, u2s_in, u2s_out);

            $display("JI");
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