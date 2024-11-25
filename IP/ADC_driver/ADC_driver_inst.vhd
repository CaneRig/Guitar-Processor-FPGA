	component ADC_driver is
		port (
			adc_pll_clock_clk       : in  std_logic                     := 'X';             -- clk
			adc_pll_locked_export   : in  std_logic                     := 'X';             -- export
			clock_clk               : in  std_logic                     := 'X';             -- clk
			reset_sink_reset_n      : in  std_logic                     := 'X';             -- reset_n
			response_valid          : out std_logic;                                        -- valid
			response_startofpacket  : out std_logic;                                        -- startofpacket
			response_endofpacket    : out std_logic;                                        -- endofpacket
			response_empty          : out std_logic_vector(0 downto 0);                     -- empty
			response_channel        : out std_logic_vector(4 downto 0);                     -- channel
			response_data           : out std_logic_vector(11 downto 0);                    -- data
			sequencer_csr_address   : in  std_logic                     := 'X';             -- address
			sequencer_csr_read      : in  std_logic                     := 'X';             -- read
			sequencer_csr_write     : in  std_logic                     := 'X';             -- write
			sequencer_csr_writedata : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			sequencer_csr_readdata  : out std_logic_vector(31 downto 0)                     -- readdata
		);
	end component ADC_driver;

	u0 : component ADC_driver
		port map (
			adc_pll_clock_clk       => CONNECTED_TO_adc_pll_clock_clk,       --  adc_pll_clock.clk
			adc_pll_locked_export   => CONNECTED_TO_adc_pll_locked_export,   -- adc_pll_locked.export
			clock_clk               => CONNECTED_TO_clock_clk,               --          clock.clk
			reset_sink_reset_n      => CONNECTED_TO_reset_sink_reset_n,      --     reset_sink.reset_n
			response_valid          => CONNECTED_TO_response_valid,          --       response.valid
			response_startofpacket  => CONNECTED_TO_response_startofpacket,  --               .startofpacket
			response_endofpacket    => CONNECTED_TO_response_endofpacket,    --               .endofpacket
			response_empty          => CONNECTED_TO_response_empty,          --               .empty
			response_channel        => CONNECTED_TO_response_channel,        --               .channel
			response_data           => CONNECTED_TO_response_data,           --               .data
			sequencer_csr_address   => CONNECTED_TO_sequencer_csr_address,   --  sequencer_csr.address
			sequencer_csr_read      => CONNECTED_TO_sequencer_csr_read,      --               .read
			sequencer_csr_write     => CONNECTED_TO_sequencer_csr_write,     --               .write
			sequencer_csr_writedata => CONNECTED_TO_sequencer_csr_writedata, --               .writedata
			sequencer_csr_readdata  => CONNECTED_TO_sequencer_csr_readdata   --               .readdata
		);

