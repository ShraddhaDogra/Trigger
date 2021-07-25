-------------------------------------------------------------------------------
--Dummy implementation of FIFO for simulation
--For production system use FPGA manufacturer IP core
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity STD_FIFO is
  generic (
    constant DATA_WIDTH : positive := 8;
    constant FIFO_DEPTH : positive := 256
    );
  port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    WriteEn : in  std_logic;
    DataIn  : in  std_logic_vector (DATA_WIDTH - 1 downto 0);
    ReadEn  : in  std_logic;
    DataOut : out std_logic_vector (DATA_WIDTH - 1 downto 0);
    Empty   : out std_logic;
    Full    : out std_logic
    );
end STD_FIFO;

architecture Behavioral of STD_FIFO is

begin

  -- Memory Pointer Process
  fifo_proc : process (CLK)
    type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of std_logic_vector (DATA_WIDTH - 1 downto 0);
    variable Memory : FIFO_Memory;

    variable Head : natural range 0 to FIFO_DEPTH - 1;
    variable Tail : natural range 0 to FIFO_DEPTH - 1;

    variable Looped : boolean;
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        Head := 0;
        Tail := 0;

        Looped := false;

        Full  <= '0';
        Empty <= '1';
      else
        if (ReadEn = '1') then
          if ((Looped = true) or (Head /= Tail)) then
                                        -- Update data output
            DataOut <= Memory(Tail);

                                        -- Update Tail pointer as needed
            if (Tail = FIFO_DEPTH - 1) then
              Tail := 0;

              Looped := false;
            else
              Tail := Tail + 1;
            end if;


          end if;
        end if;

        if (WriteEn = '1') then
          if ((Looped = false) or (Head /= Tail)) then
                                        -- Write Data to Memory
            Memory(Head) := DataIn;

                                        -- Increment Head pointer as needed
            if (Head = FIFO_DEPTH - 1) then
              Head := 0;

              Looped := true;
            else
              Head := Head + 1;
            end if;
          end if;
        end if;

        -- Update Empty and Full flags
        if (Head = Tail) then
          if Looped then
            Full <= '1';
          else
            Empty <= '1';
          end if;
        else
          Empty <= '0';
          Full  <= '0';
        end if;
      end if;
    end if;
  end process;

end Behavioral;
