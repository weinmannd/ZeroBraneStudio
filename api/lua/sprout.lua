return {
    Hy = {
        type = "class",
        description = "The Hy namespace contains properties relevant to the current instance of the running Lua script, and a couple of utility methods.",
        childs = {
            bAbort = {
                type = "value",
                description = "(Read Only) Contains true if the Lua script should abort its operation. You should check this flag periodically, especially during lenghty operations."
            },
            oProject = {
                type = "value",
                description = "(Read Only) Contains an instance of the Hy.Project class, which represents the current project. Projects are shown as tabs in the user interface."
            },
            DisplayProgress = {
                type = "function",
                description = "This method allows the Lua script to display progress information during long operations. The second argument should increase from 0 to 1, with 1 indicating task completion.",
                args = "(strName, dProgress)",
                returns = "()"
            }
        }
    },
    RS232 = {
        type = "class",
        description = "If an argument is provided, this constructor creates the object, and immediately tries to open the specified port with default settings. If no argument is provided, or if the argument is an empty string, the object is constructed without opening a port.",
        args = (strPortName),
        childs = {
            bCD = {
                type="value",
                description="(Read Only) The current status of the CD line."
            },
            bCTS  = {
                type="value",
                description="(Read Only) The current status of the CTS line."
            }, 
            Flush = {
                type="function",
                description="Flushes both input and output buffers.",
            }
        }
    }
}