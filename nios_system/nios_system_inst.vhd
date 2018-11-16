	component nios_system is
		port (
			clk_clk                                : in  std_logic := 'X'; -- clk
			reset_reset_n                          : in  std_logic := 'X'; -- reset_n
			tse_mac_mac_status_connection_set_10   : in  std_logic := 'X'; -- set_10
			tse_mac_mac_status_connection_set_1000 : in  std_logic := 'X'; -- set_1000
			tse_mac_mac_status_connection_eth_mode : out std_logic;        -- eth_mode
			tse_mac_mac_status_connection_ena_10   : out std_logic         -- ena_10
		);
	end component nios_system;

	u0 : component nios_system
		port map (
			clk_clk                                => CONNECTED_TO_clk_clk,                                --                           clk.clk
			reset_reset_n                          => CONNECTED_TO_reset_reset_n,                          --                         reset.reset_n
			tse_mac_mac_status_connection_set_10   => CONNECTED_TO_tse_mac_mac_status_connection_set_10,   -- tse_mac_mac_status_connection.set_10
			tse_mac_mac_status_connection_set_1000 => CONNECTED_TO_tse_mac_mac_status_connection_set_1000, --                              .set_1000
			tse_mac_mac_status_connection_eth_mode => CONNECTED_TO_tse_mac_mac_status_connection_eth_mode, --                              .eth_mode
			tse_mac_mac_status_connection_ena_10   => CONNECTED_TO_tse_mac_mac_status_connection_ena_10    --                              .ena_10
		);

