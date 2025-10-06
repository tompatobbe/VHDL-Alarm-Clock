library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clock_to_lcd is
port(

			clk : in std_logic;
			reset : in std_logic;
			seconds : in std_logic_vector(6 downto 0);
			minute : in std_logic_vector(6 downto 0);
			hour : in std_logic_vector(6 downto 0);
			
			en : out std_logic;
			on1 : out std_logic;
			bl : out std_logic;
			rs : out std_logic;
			rw : out std_logic;
			data : out std_logic_vector(7 downto 0)

);
end entity;

architecture behavior of clock_to_lcd is

signal second1 : std_logic_vector(3 downto 0);
signal second2 : std_logic_vector(3 downto 0);
signal minute1 : std_logic_vector(3 downto 0);
signal minute2 : std_logic_vector(3 downto 0);
signal hour1 : std_logic_vector(3 downto 0);
signal hour2 : std_logic_vector(3 downto 0);

signal seconds_int : integer range 0 to 127;
signal minute_int : integer range 0 to 127;
signal hour_int : integer range 0 to 127;

constant clk_goal : integer := 820000;
constant enable_clk_goal1: integer :=  200000;
constant enable_clk_goal2: integer :=  600000;
signal clk_count : integer := 0;


function bin_to_ascii (bin: std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case bin is
            when "0000" => return "00110000"; 
            when "0001" => return "00110001";  
            when "0010" => return "00110010";  
            when "0011" => return "00110011";  
            when "0100" => return "00110100";  
            when "0101" => return "00110101";  
            when "0110" => return "00110110";  
            when "0111" => return "00110111";  
            when "1000" => return "00111000";  
            when "1001" => return "00111001"; 
				when "1010" => return "00100000";
            when others => return "00111111";
        end case;
    end function;

type state_type is (setup1,setup2,setup3,setup4,enter_data1,enter_data2,enter_data3,enter_data4,enter_data5,enter_data6,enter_data7,enter_data8);
signal state : state_type;

begin

-- The backlight and on signals are obviously always on
    bl <= '1';
    on1 <= '1';

	 
	 process(clk,reset)
		begin
		-- Reset logic
		if reset = '0' then
		clk_count <= 0;
		rs <= '0';
      rw <= '0';
      en <= '0';
		state <= setup1; 
		data <= "00000000";
		elsif rising_edge(clk) then
			
			seconds_int <= to_integer(unsigned(seconds));
			minute_int <= to_integer(unsigned(minute));
			hour_int <= to_integer(unsigned(hour));

			
			if seconds_int > 59 then
				 second1 <= "1010"; -- Space
				 second2 <= "1010";
			else
				 second1 <= std_logic_vector(to_unsigned(seconds_int / 10, 4));
				 second2 <= std_logic_vector(to_unsigned(seconds_int mod 10, 4));
			end if;

			if minute_int > 59 then
				 minute1 <= "1010"; -- Space
				 minute2 <= "1010";
			else
				 minute1 <= std_logic_vector(to_unsigned(minute_int / 10, 4));
				 minute2 <= std_logic_vector(to_unsigned(minute_int mod 10, 4));
			end if;

			if hour_int > 23 then
				 hour1 <= "1010"; -- Space
				 hour2 <= "1010";
			else
				 hour1 <= std_logic_vector(to_unsigned(hour_int / 10, 4));
				 hour2 <= std_logic_vector(to_unsigned(hour_int mod 10, 4));
			end if;
			
			
			if seconds > "111011" then
				second1 <= "1010";
				second2 <= "1010";
			elsif minute > "111011" then
				minute1 <= "1010";
				minute2 <= "1010";
			elsif hour > "11000" then
				hour1 <= "1010";
				hour2 <= "1010";
			end if;
						
			if clk_count = enable_clk_goal1 then
			en <= '1';
			clk_count <= clk_count + 1;
			
			elsif clk_count = enable_clk_goal2 then
			en <= '0';
			clk_count <= clk_count + 1;
			
			
			elsif clk_count = clk_goal - 1 then
			clk_count <= 0;
				case state is
				
					when setup1 => --8-bit mode
						rs <= '0';
						rw <= '0';
						data <= "00111000";
						state <= setup2;
							
					when setup2 => -- Clear display
						rs <= '0';
						rw <= '0';
						data <= "00000001";  
						state <= setup3;
					
					when setup3 => -- Display on (no cursor)
						rs <= '0';
						rw <= '0';
						data <= "00001100";
						state <= setup4;
					
					when setup4 => 	-- Return home
						rs <= '0';
						rw <= '0';
						data <= "00000010";
						state <= enter_data1;
					
					when enter_data1 =>
						rs <= '1';
						rw <= '0';
						data <= bin_to_ascii(hour1);
						state <= enter_data2;
					
					when enter_data2 =>
						rs <= '1';
						rw <= '0';
						data <= bin_to_ascii(hour2);
						state <= enter_data3;
						
					when enter_data3 =>
						rs <= '1';
						rw <= '0';
						data <= "00111010";
						state <= enter_data4;
						
					when enter_data4 =>
						rs <= '1';
						rw <= '0';
						data <= bin_to_ascii(minute1);
						state <= enter_data5;
						
					when enter_data5 =>
						rs <= '1';
						rw <= '0';
						data <= bin_to_ascii(minute2);
						state <= enter_data6;
					
					when enter_data6 =>
						rs <= '1';
						rw <= '0';
						data <= "00111010";
						state <= enter_data7;
						
					when enter_data7 =>
						rs <= '1';
						rw <= '0';
						data <= bin_to_ascii(second1);
						state <= enter_data8;
						
					when enter_data8 =>
						rs <= '1';
						rw <= '0';
						data <= bin_to_ascii(second2);
						state <= setup4;
						
				end case;
			else
				clk_count <= clk_count + 1;
			end if;
		end if;
	end process;

end architecture;