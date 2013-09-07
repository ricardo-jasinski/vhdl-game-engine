library ieee;
use ieee.std_logic_1164.all;

entity system_timing is
    generic (
        TIMESTAMP_COUNTER_MAX: integer := 1000
    );
    port (
        clock_50MHz : in std_logic;
        reset : in std_logic;
        time_base_50_ms_out: out std_logic;
        elapsed_time_out: out integer range 0 to TIMESTAMP_COUNTER_MAX
    );
end;

architecture rtl of system_timing is
    constant COUNTER_50_MS_MAX: integer := 50_000_000 / 20; -- 100 ms / 20 ns
    signal counter_50_ms: integer range 0 to COUNTER_50_MS_MAX;
    signal time_base_50_ms: std_logic;
    signal elapsed_time: integer range 0 to TIMESTAMP_COUNTER_MAX;
begin
    elapsed_time_out <= elapsed_time;
    time_base_50_ms_out <= time_base_50_ms;

    process (clock_50MHz, reset) begin
        if reset then
            time_base_50_ms <= '0';
            counter_50_ms <= 0;
        elsif rising_edge(clock_50MHz) then
            if counter_50_ms < COUNTER_50_MS_MAX then
                counter_50_ms <= counter_50_ms + 1;
                time_base_50_ms <= '0';
            else
                counter_50_ms <= 0;
                time_base_50_ms <= '1';
            end if;
        end if;
    end process;

    process (clock_50MHz, reset) begin
        if reset then
            elapsed_time <= 0;
        elsif rising_edge(clock_50MHz) then
            if time_base_50_ms then
                elapsed_time <= elapsed_time + 1;
            end if;
        end if;
    end process;
end;
