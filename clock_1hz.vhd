library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;
entity clk_1hz is

	port (
		clk : in std_logic ;
		clk_1hz : out std_logic 
		);
	
end clk_1hz;

architecture Behavioral of clk_1hz is

signal temp : std_logic := '0';
signal count : integer := 0;

begin
	process(clk)
		begin
			if rising_edge(clk) then
				count <= count + 1;
				if (count = 24_999_999) then
					temp <= not temp;
					count <= 0;
				end if;
			end if;
			clk_1hz <= temp;
	end process;

end Behavioral;