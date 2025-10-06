Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_digit_alarm_display is
	port ( 
		count : in std_logic_vector(6 downto 0);
		clk_50mhz : in std_logic;
		tens_out : out std_logic_vector(6 downto 0);
		singles_out : out std_logic_vector(6 downto 0)	
			);
end two_digit_alarm_display;

architecture rtl of two_digit_alarm_display is
	signal tens, singles, number : integer range 0 to 64;
	begin
		
			
		process(clk_50mhz)
			begin
			if count > "111011" then
				singles_out <= "1111111";
				tens_out <= "1111111";
			else
				number <= to_integer(unsigned(count));
				
				tens <= number / 10;
				singles <= number mod 10;
			
				case singles is
				  when 0 => singles_out <= "1000000"; -- 0
				  when 1 => singles_out <= "1111001"; -- 1
				  when 2 => singles_out <= "0100100"; -- 2
				  when 3 => singles_out <= "0110000"; -- 3
				  when 4 => singles_out <= "0011001"; -- 4
				  when 5 => singles_out <= "0010010"; -- 5
				  when 6 => singles_out <= "0000010"; -- 6
				  when 7 => singles_out <= "1111000"; -- 7
				  when 8 => singles_out <= "0000000"; -- 8
				  when 9 => singles_out <= "0010000"; -- 9
				  when others => singles_out <= "1111111"; 
				end case;
				
				case tens is
				  when 0 => tens_out <= "1000000"; -- 0
				  when 1 => tens_out <= "1111001"; -- 1
				  when 2 => tens_out <= "0100100"; -- 2
				  when 3 => tens_out <= "0110000"; -- 3
				  when 4 => tens_out <= "0011001"; -- 4
				  when 5 => tens_out <= "0010010"; -- 5
				  when 6 => tens_out <= "0000010"; -- 6
				  when 7 => tens_out <= "1111000"; -- 7
				  when 8 => tens_out <= "0000000"; -- 8
				  when 9 => tens_out <= "0010000"; -- 9
				  when others => tens_out <= "1111111"; 
				end case;
			end if;
		end process;	
end rtl;