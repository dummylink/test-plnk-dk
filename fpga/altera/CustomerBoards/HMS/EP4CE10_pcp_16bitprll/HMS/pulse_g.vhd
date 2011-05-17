
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity pulse_g is

	port
	(
		clk_96MHz	  : in std_logic;
		PDI_write_in  : in std_logic;
		PDI_write_out : out std_logic
	);

end entity;

architecture rtl of pulse_g is
begin

	process (clk_96MHz, PDI_write_in)
       variable count : std_logic_vector (1 downto 0);
	begin

		if (rising_edge(clk_96MHz)) then

			if (PDI_write_in = '1') then
			   
			   count := (others => '0');

            elsif (count<3) then

               count := count + 1;

			end if;

		end if;

        -- Output the current count
        PDI_write_out <= PDI_write_in or (count(1) and count(0));

    end process;
					

end rtl;
