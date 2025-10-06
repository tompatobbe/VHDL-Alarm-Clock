Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mode_selector is
    port ( 
        clk_50mhz : in std_logic;
        reset : in std_logic;
        mode : in std_logic;
        set : in std_logic;
        mode_out : out std_logic_vector(2 downto 0);
        add_min : out std_logic;
        add_hour : out std_logic;
        LED_out : out std_logic_vector(2 downto 0)
    );
end mode_selector;

architecture Behavioral of mode_selector is 
    type state_type is (IDLE, SELECT_TIME_MIN, SELECT_TIME_HOUR, ALARM_ON, CHANGE_ALARM_MIN, CHANGE_ALARM_HOUR);
    signal state : state_type := IDLE;
    signal q1_mode, q2_mode, q1_set, q2_set : std_logic := '0';
    signal add_min_reg, add_hour_reg : std_logic := '0';
begin 
    -- Button debouncing and edge detection
    process(clk_50mhz)
    begin
        if rising_edge(clk_50mhz) then
            if reset = '0' then
                q1_mode <= '0';
                q2_mode <= '0';
                q1_set <= '0';
                q2_set <= '0';

            else
                -- Simple debounce mechanism
                if (q1_set /= q2_set) or (q1_mode /= q2_mode) then
                    q2_mode <= q1_mode;
                    q1_mode <= mode;
                    q2_set <= q1_set;
                    q1_set <= set;
                else
                    q2_mode <= q1_mode;
                    q1_mode <= mode;
                    q2_set <= q1_set;
                    q1_set <= set;
                end if;
            end if;
        end if;
    end process;
    
    -- State machine process
    process(clk_50mhz)
    begin
        if rising_edge(clk_50mhz) then
                -- Clear the pulse signals after one clock cycle
                add_min_reg <= '0';
                add_hour_reg <= '0';
					 if reset = '0' then
						 state <= IDLE;
					 end if;
                
                case state is
                    when IDLE =>
                        LED_out <= "000";
                        mode_out <= "000";
                        if (q1_set = '1' and q2_set = '0') then
                            state <= ALARM_ON;
                        elsif (q1_mode = '1' and q2_mode = '0') then 
                            state <= SELECT_TIME_MIN;
                        end if;
                        
                    when SELECT_TIME_MIN =>
                        LED_out <= "100";
                        mode_out <= "100";
                        if (q1_mode = '1' and q2_mode = '0') then
                            state <= SELECT_TIME_HOUR;
                        elsif (q1_set = '1' and q2_set = '0') then
                            add_min_reg <= '1';
                        end if;
                    
                    when SELECT_TIME_HOUR =>
                        LED_out <= "101";
                        mode_out <= "101";
                        if (q1_mode = '1' and q2_mode = '0') then
                            state <= IDLE;
                        elsif (q1_set = '1' and q2_set = '0') then
                            add_hour_reg <= '1';
                        end if;
                    
                    when ALARM_ON =>
                        LED_out <= "001";
                        mode_out <= "001";
                        if (q1_set = '1' and q2_set = '0') then
                            state <= IDLE;
                        elsif (q1_mode = '1' and q2_mode = '0') then
                            state <= CHANGE_ALARM_MIN;
                        end if;
                        
                    when CHANGE_ALARM_MIN =>
                        LED_out <= "010";
                        mode_out <= "010";
                        if (q1_mode = '1' and q2_mode = '0') then
                            state <= CHANGE_ALARM_HOUR;
                        elsif (q1_set = '1' and q2_set = '0') then
                            add_min_reg <= '1';
                        end if;
                    
                    when CHANGE_ALARM_HOUR =>
                        LED_out <= "011";
                        mode_out <= "011";
                        if (q1_mode = '1' and q2_mode = '0') then
                            state <= ALARM_ON;
                        elsif (q1_set = '1' and q2_set = '0') then
                            add_hour_reg <= '1';
                        end if;
                end case;
        end if;
    end process;
    
    -- Assign output signals
    add_min <= add_min_reg;
    add_hour <= add_hour_reg;
end Behavioral;