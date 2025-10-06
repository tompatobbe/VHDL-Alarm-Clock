Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_merge is
	port ( 
		clk_50mhz : in std_logic;
		mode : in std_logic_vector(2 downto 0);
		seconds_clock : in std_logic_vector(6 downto 0);
		minutes_clock : in std_logic_vector(6 downto 0);
		hours_clock : in std_logic_vector(6 downto 0);
		minutes_alarm : in std_logic_vector(6 downto 0);
		hours_alarm : in std_logic_vector(6 downto 0);
		
		seconds_out : out std_logic_vector(6 downto 0);
		minutes_out : out std_logic_vector(6 downto 0);
		hours_out : out std_logic_vector(6 downto 0);
		BUZZ : out std_logic
			);
end clock_merge;


architecture Behavioral of clock_merge is 
-- Blinking signal for editing modes
signal blink_counter : integer range 0 to 25000000 := 0;
signal blink_state : std_logic := '1';

begin 
	-- Blinking process for editing indicators
	process(clk_50mhz)
	begin
		if rising_edge(clk_50mhz) then
			if blink_counter = 25000000 then  -- 0.5 second blink rate
				blink_state <= not blink_state;
				blink_counter <= 0;
			else
				blink_counter <= blink_counter + 1;
			end if;
		end if;
	end process;

	-- Multiplexing process based on mode
	process(clk_50mhz)
	begin
		if rising_edge(clk_50mhz) then
			-- Always forward the clock values directly in all modes
			-- This ensures that the time values set in SELECT_TIME modes
			-- are visible as soon as the mode changes back to IDLE
			seconds_out <= seconds_clock;
			minutes_out <= minutes_clock;
			hours_out <= hours_clock;
			
			-- Apply blinking effects for edit modes only
			case mode is
				when "010" => -- CHANGE_ALARM_MIN: Show alarm time with minutes blinking
					seconds_out <= (others => '1');  -- Turn off seconds display during alarm setting
					hours_out <= hours_alarm;
					
					-- Blink minutes when setting them
					if blink_state = '1' then
						minutes_out <= minutes_alarm;
					else
						minutes_out <= (others => '1');  -- Blank display during blink off
					end if;
				
				when "011" => -- CHANGE_ALARM_HOUR: Show alarm time with hours blinking
					seconds_out <= (others => '1');  -- Turn off seconds display during alarm setting
					minutes_out <= minutes_alarm;
					
					-- Blink hours when setting them
					if blink_state = '1' then
						hours_out <= hours_alarm;
					else
						hours_out <= (others => '1');  -- Blank display during blink off
					end if;
					
				when "100" => -- SELECT_TIME_MIN: Set clock minutes (blinking)
					-- Blink minutes when setting them
					if blink_state = '1' then
						minutes_out <= minutes_clock;
					else
						minutes_out <= (others => '1');  -- Blank display during blink off
					end if;
					
				when "101" => -- SELECT_TIME_HOUR: Set clock hours (blinking)
					-- Blink hours when setting them
					if blink_state = '1' then
						hours_out <= hours_clock;
					else
						hours_out <= (others => '1');  -- Blank display during blink off
					end if;
					
				when "001" =>
					if (minutes_clock = minutes_alarm and hours_clock = hours_alarm) then
						if blink_state = '1' then
							BUZZ <= '1';
						else
							BUZZ <= '0';
						end if;
					end if;
					
				when "000" =>
					BUZZ <= '0';
				when others =>
			end case;
		end if;
	end process;
end Behavioral;