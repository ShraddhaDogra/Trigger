The FEE monitor:

1) Include all files into your project.
2) Rewrite monitor_config.vhd
3) Assign all signals to be monitored to the FIFO input port and REG input port.
4) Read values out via trbcmd or slowcontrol

Attach the monitor to the regio bus handler entity with a designated address range.
In case of 0xb000 address space, the cells would be:

   0xb100 - 0xb1xx configuration cells, use writes to set FIFO parameter
            write 0x1 - FIFO RESET
            write 0x2 - Ring Buffer Mode
            write 0x4 - Diff, check if successive inputs differ,
                        writes only new and changed values into the FIFO
            write 0x8 - HALT the FIFO writes
           write 0x10 - Automatic monitoring with predefined frequency
                        The frequency is set by freq_low which sais
                        how many clock cycles should be skipped and
                        freq_high which sais how many clock cycles
                        as a power of 2 should be skipped.
                        If freq_high is set, freq_low will be ignored.

                        If no automatic scanning is specified, use
                        FIFO_WRITE_IN port to set HW write triggers.
                        One bit per FIFO, if it is set then a write occurs.
            Any combination of these is also possible.
   0xb200 - 0xb2xx FIFO cell address range, one address per FIFO
   0xb300 - 0xb3xx REG cell address range, one address per Register

In the current version, the ROM is not implemented.


Borislav Milanovic
