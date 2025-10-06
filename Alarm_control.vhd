Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Alarm_control is
	port ( 
		clk_50mhz : in std_logic;
		add_hour : in std_logic;
		add_minute : in std_logic;
		mode : in std_logic_vector(2 downto 0);
		reset : in std_logic;
		
		minutes_out : out std_logic_vector(6 downto 0);
		hours_out : out std_logic_vector(6 downto 0)
			);
end Alarm_control;


architecture Behavioral of Alarm_control is 
-- Internal signals
signal minutes : integer range 0 to 59;
signal hours : integer range 0 to 23;
signal add_hour_prev : std_logic := '0';
signal add_minute_prev : std_logic := '0';

begin 
	process(clk_50mhz)
	begin
		if rising_edge(clk_50mhz) then
			if reset = '0' then  -- Active low reset
            minutes <= 0;
            hours <= 0;
            add_hour_prev <= '0';
            add_minute_prev <= '0';
        else
			-- Edge detection for button presses
			add_hour_prev <= add_hour;
			add_minute_prev <= add_minute;
			
			-- Update alarm time when in alarm setting modes (010 for minutes, 011 for hours)
				if mode = "010" then  -- CHANGE_ALARM_MIN mode
					if add_minute = '1' and add_minute_prev = '0' then
						if minutes = 59 then
							minutes <= 0;
						else
							minutes <= minutes + 1;
						end if;
					end if;
				elsif mode = "011" then  -- CHANGE_ALARM_HOUR mode
					if add_hour = '1' and add_hour_prev = '0' then
						if hours = 23 then
							hours <= 0;
						else
							hours <= hours + 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- Convert integers to std_logic_vector for output
	minutes_out <= std_logic_vector(to_unsigned(minutes, 7));
	hours_out <= std_logic_vector(to_unsigned(hours, 7));
	
end Behavioral;