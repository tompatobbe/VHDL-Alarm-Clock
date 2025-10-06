library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_counter is
    port (
        clk_50mhz : in std_logic;
        clk_1hz : in std_logic;
        reset : in std_logic;

        seconds_out : out std_logic_vector(6 downto 0);
        minutes_out : out std_logic_vector(6 downto 0);
        hours_out : out std_logic_vector(6 downto 0);

        add_min : in std_logic;
        add_hour : in std_logic;

        mode : in std_logic_vector(2 downto 0)
    );
end clock_counter;

architecture Behavioral of clock_counter is
    signal clk_1hz_prev : std_logic := '0';
    signal tick_1hz : std_logic := '0';

    signal seconds : integer range 0 to 59 := 0;
    signal minutes : integer range 0 to 59 := 0;
    signal hours : integer range 0 to 23 := 0;

    signal min_change : integer range 0 to 59 := 0;
    signal hour_change : integer range 0 to 23 := 0;

    signal displayed_minutes : integer range 0 to 59;
    signal displayed_hours : integer range 0 to 23;

    signal add_min_prev, add_hour_prev : std_logic := '0';
    signal prev_mode : std_logic_vector(2 downto 0) := "000";
    signal just_left_time_set : std_logic := '0';
begin

    -- Edge detection for 1Hz clock
    process(clk_50mhz)
    begin
        if rising_edge(clk_50mhz) then
            clk_1hz_prev <= clk_1hz;
            if clk_1hz_prev = '0' and clk_1hz = '1' then
                tick_1hz <= '1';
            else
                tick_1hz <= '0';
            end if;
        end if;
    end process;

    -- Main counter logic
    process(clk_50mhz)
    begin
        if rising_edge(clk_50mhz) then
            -- Button edge detection
            add_min_prev <= add_min;
            add_hour_prev <= add_hour;

            if reset = '0' then
                seconds <= 0;
                minutes <= 0;
                hours <= 0;
                min_change <= 0;
                hour_change <= 0;
            else
                -- Detect leaving time-set mode and apply new values
                if (prev_mode = "100" or prev_mode = "101") and not (mode = "100" or mode = "101") then
                    minutes <= min_change;
                    hours <= hour_change;
                    just_left_time_set <= '1';
                end if;

                -- Store previous mode
                prev_mode <= mode;					

                if mode = "100" then  -- SELECT_TIME_MIN
                    if add_min = '1' and add_min_prev = '0' then
                        if min_change = 59 then
                            min_change <= 0;
                        else
                            min_change <= min_change + 1;
                        end if;
                    end if;

                elsif mode = "101" then  -- SELECT_TIME_HOUR
                    if add_hour = '1' and add_hour_prev = '0' then
                        if hour_change = 23 then
                            hour_change <= 0;
                        else
                            hour_change <= hour_change + 1;
                        end if;
                    end if;

                else  -- Normal time counting mode
                    if tick_1hz = '1' and just_left_time_set = '0' then
                        if seconds = 59 then
                            seconds <= 0;
                            if minutes = 59 then
                                minutes <= 0;
                                if hours = 23 then
                                    hours <= 0;
                                else
                                    hours <= hours + 1;
                                end if;
                            else
                                minutes <= minutes + 1;
                            end if;
                        else
                            seconds <= seconds + 1;
                        end if;
                    end if;
                    -- Reset flag after one cycle
                    just_left_time_set <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Updated outputs based on mode
    process(mode, min_change, hour_change, minutes, hours)
    begin
        -- Adjust displayed minutes and hours based on the mode
        if mode = "100" or mode = "010" then
            displayed_minutes <= min_change; -- In minute adjustment mode, use min_change
        else
            displayed_minutes <= minutes;  -- Otherwise, use normal minutes
        end if;

        if mode = "101" or mode = "011" then
				displayed_minutes <= min_change;
            displayed_hours <= hour_change; -- In hour adjustment mode, use hour_change
        else
            displayed_hours <= hours;  -- Otherwise, use normal hours
        end if;
    end process;

    -- Outputs
    seconds_out <= std_logic_vector(to_unsigned(seconds, 7));
    minutes_out <= std_logic_vector(to_unsigned(displayed_minutes, 7));
    hours_out   <= std_logic_vector(to_unsigned(displayed_hours, 7));

end Behavioral;
