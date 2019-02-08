local Project = {
    type = "class",
    description = "The central hub of the API is the Hy.Project class. You can obtain an instance representing the current project from the Hy.oProject property. The project in turn gives you access to the current printer and material, and the density field resulting from applying the project's 'recipe'. This is the main class of the API, representing an open project in the app (shown as a tab in the user interface). Constructs a new, empty project, which will be using the specified printer profile. Creating new projects, while possible, is currently not very useful. Instead, obtain the current project from the Hy.oProject property.",
    childs = {
        dLayerThickness = {
            type = "value",
            description = "(Read Only) The current layer thickness in project units (i.e. millimeters)."
        },
        oMaterial = {
            type = "value",
            description = "(Read Only) Contains an instance of the Hy.Material class, providing access to the current material."
        },
        oPrinter = {
            type = "value",
            description = "(Read Only) Contains an instance of the Hy.Printer class, providing access to the printer profile associated with the project."
        },
        oProduceResult = {
            type= "function",
            description = "This function produces the result of the project's recipe, and returns it as a density field (Hy.DensityField instance). The host app prepares the recipe result in the background, but depending on the situation, it might not be available right away. Therefore, the oProduceResult() function can take a long time to complete. If the project's recipe doesn't have a valid result, for example because there's no geometry loaded, this function returns nil.",
            args = "()",
            returns = "(oDensityField)",
            valuetype = "Hy.DensityField"
        }
    }
}

local Material = {
    type = "class",
    description = "This class provides information about the current material. Constructs an empty material. This is currently not very useful, since materials are read-only at the moment.",
    childs = {
        strName  = {
            type = "value",
            description = "(Read Only) Contains the full name of the material as defined in the material XML file, i.e. 'Opaque Black Resin'."
        },
        strGetProperty = {
            type= "function",
            description = "Returns an arbitrarily-named property of the material, or an empty string if such a property was not defined in the material XML file. Note that materials inherit properties from their parents, (material groups or other materials) and this function automatically resolves these inheritances.",
            args = "(strName)",
            returns = "(strProperty)"
        }
    }
}

local Printer = {
    type = "class",
    description = "This class provides information about the printer associated with a project, as defined in its XML profile. Constructs an empty printer. This is currently not very useful, since printers are read-only at the moment.",
    childs = {
        strManufacturer  = {
            type = "value",
            description = "(Read Only) The name of the printer manufacturer."
        },
        strModel = {
            type = "value",
            description = "(Read Only) The model name of the printer."
        }
    }
}

local DensityField = {
    type = "class",
    description = "This class represents a voxel field containing information about local material density, ranging from 0 (air) to 1 (solid material). Constructs an empty density field with the specified data window, and voxel size. A voxel field's data window is the range of coordinates, for which the field contains valid values. Outside the data window, the field returns 0, and ignores write attempts.",
    args = "(Hy.Box: oDataWindow, Hy.VoxelSize: oVoxelSize)",
    childs = {
        oBoundingBox  = {
            type = "value",
            description = "(Read Only) Contains the axis-aligned bounding box of all voxels within the density field, which have a value of 0.5 or more."
        },
        oDataWindow  = {
            type = "value",
            description = "Contains the data window of the density field. When this property is changed, the data window of the density field will be expanded to contain both the old and new data windows. The contents of the field will be preserved."
        },
        oVoxelSize  = {
            type = "value",
            description = "Contains the voxel size of the density field. Note that changing the voxel size of the filed does not change its contents, (no resampling takes place) and thus the overall size of the field in project units will change."
        },
        oGetSlice = {
            type= "function",
            description = "Reads a horizontal (i.e. perpendicular to the Z axis) slice from the density field at the specified Z coordinate (in voxels) as an instance of Hy.DensitySlice. Use the dUnitsToVoxels function of Hy.VoxelSize to convert from project units to voxels if necessary. Note that if dZ is not a whole number, the returned slice will contain interpolated values. This is useful for example if the printer layer thickness doesn't match the voxel size.",
            args = "(dZ)",
            returns = "(oSlice)",
            valuetype = "Hy.DensitySlice"
        }
    }
}

local DensitySlice = {
    type = "class",
    description = "This class represents a 2-dimensional slice of a density field. Constructs an empty density slice with the specified data window, and voxel size. A slice's data window is the range of coordinates, for which it contains valid values. Outside the data window, the slice returns 0, and ignores write attempts.",
    args = "(Hy.Rect: oDataWindow, Hy.VoxelSize: oVoxelSize)",
    childs = {
        oDataWindow  = {
            type = "value",
            description = "(Read Only) Returns a Hy.Rect with the slice's data window.",
            valuetype = "Hy.Rect"
        },
        dGetValue = {
            type= "function",
            description = "Returns the density at the specified voxel coordinates. The coordinates have to be within the data window, otherwise 0 will be returned. Density ranges from 0 (air) to 1 (solid material). If non-integer coordinates are used, the function currently returns the value of the nearest voxel, without interpolation. This will most likely change in the near future to include bilinear interpolation, so it is best to round coordinates explicitly, if an exact value is desired. It is advisable to use the dUnitsToVoxels function of Hy.VoxelSize for the conversion from project units to voxels. Note that the dUnitsToVoxels function returns non-integer values.",
            args = "(dX, dY)",
            returns = "(dDensity)",
        },
        dLargestIslandAreaVoxels = {
            type= "function",
            description = "Finds the largest 'island' within the slice, defined as a continuous area of voxels with density >= 0.5, and calculates its area in voxels. Only voxels with density >= 0.5 are considered in the area calculation.",
            args = "()",
            returns = "(dArea)",
        },
        SetValue = {
            type= "function",
            description = "Sets the density at the specified voxel coordinates. If coordinates lie outside the slice's data window, the call has no effect. It is advisable to use the dUnitsToVoxels function of Hy.VoxelSize for the conversion from project units to voxels. Non-integer coordinates will be rounded to the nearest voxel.",
            args = "(iX, iY, dDensity)",
            returns = "()",
        },
        Fill = {
            type= "function",
            description = "Fills the entire slice with the specified density value.",
            args = "(dDensity)",
            returns = "()",
        }
    }
}

-- Support Classes: These are utility classes used by other, higher-level classes and functions.

local Box = {
    type = "class",
    description = "Hy.Box represents a 3-dimensional box with integer coordinates. It's mostly used for data ranges and bounding boxes in voxel fields. The box is defined in such a way that it does not include the maximum coordinates, or in other words, in a box with minimum coordinates of [0, 0, 0] and maximum coordinates of [3, 3, 3], the valid positions are [0, 0, 0] to [2, 2, 2]. Constructs a box with the given coordinates (all of which are optional, and default to 0).",
    args = "(iMinX = 0, iMinY = 0, iMinZ = 0, iMaxX = 0, iMaxY = 0, iMaxZ = 0)",
    childs = {
        bIsEmpty = {
            type = "value",
            description = "(Read Only) Contains true if the box is empty, i.e. if maximum <= minimum."
        },
        iMaxX = {
            type = "value",
            description = "Maximum coordinate X."
        },
        iMaxY = {
            type = "value",
            description = "Maximum coordinate Y."
        },
        iMaxZ = {
            type = "value",
            description = "Maximum coordinate Z."
        },
        iMinX = {
            type = "value",
            description = "Minimum coordinate X."
        },
        iMinY = {
            type = "value",
            description = "Minimum coordinate Y."
        },
        iMinZ = {
            type = "value",
            description = "Minimum coordinate Z."
        },
        iSizeX = {
            type = "value",
            description = "Size of the box. Defined as max - min."
        },
        iSizeY = {
            type = "value",
            description = "Size of the box. Defined as max - min."
        },  
        iSizeZ = {
            type = "value",
            description = "Size of the box. Defined as max - min."
        }
    }
}

local Rect = {
    type = "class",
    description = "Hy.Rect is a 2-dimensional rectangle with integer coordinates. It's used for data ranges in voxel field slices. The rectangle is defined in such a way that it does not include the maximum coordinates, or in other words, in a rectangle with minimum coordinates of [0, 0] and maximum coordinates of [3, 3], the valid positions are [0, 0] to [2, 2]. Constructs a rectangle with the given coordinates (all of which are optional, and default to 0).",
    args = "(iMinX = 0, iMinY = 0, iMaxX = 0, iMaxY = 0)",
    childs = {
        bIsEmpty = {
            type = "value",
            description = "(Read Only) Contains true if the rectangle is empty, i.e. if maximum <= minimum."
        },
        iMaxX = {
            type = "value",
            description = "Maximum coordinate X."
        },
        iMaxY = {
            type = "value",
            description = "Maximum coordinate Y."
        },
        iMinX = {
            type = "value",
            description = "Minimum coordinate X."
        },
        iMinY = {
            type = "value",
            description = "Minimum coordinate Y."
        },
        iSizeX = {
            type = "value",
            description = "Size of the rectangle. Defined as max - min."
        },
        iSizeY = {
            type = "value",
            description = "Size of the rectangle. Defined as max - min."
        }
    }
}

local VoxelSize = {
    type = "class",
    description = "Hy.VoxelSize represents a particular voxel size, and provides function for coordinate transformations between voxels and project units (i.e. millimeters) with the proper offset. Constructs a Hy.VoxelSize object with the number of voxels per project unit (i.e. millimeter). The number of voxels per unit has to be a whole, positive number.",
    args = "(nVoxelsPerUnit)",
    childs = {
        dDiagonal = {
            type = "value",
            description = "(Read Only) The diagonal distance between voxel field samples."
        },
        dSize = {
            type = "value",
            description = "(Read Only) The orthogonal distance between voxel field samples. Also referred to as voxel size."
        },
        nVoxelsPerUnit = {
            type = "value",
            description = "(Read Only) Number of voxel field samples per one project unit."
        },
        dUnitsToVoxels = {
            type= "function",
            description = "Converts a coordinate (not a dimension!) from project units to voxels. This function is designed to deal with the internal voxel field sampling offset. To convert a dimension, simply multiply it by the nVoxelsPerUnit property.",
            args = "(dUnits)",
            returns = "(dVoxels)"
        },
        dVoxelsToUnits = {
            type= "function",
            description = "Converts a coordinate (not a dimension!) from voxels to project units. This function is designed to deal with the internal voxel field sampling offset. To convert a dimension, simply divide it by the nVoxelsPerUnit property.",
            args = "(dVoxels)",
            returns = "(dUnits)"
        }
    }
}

-- TODO: Add constants
local RS232 = {
    type = "class",
    description = "If an argument is provided, this constructor creates the object, and immediately tries to open the specified port with default settings. If no argument is provided, or if the argument is an empty string, the object is constructed without opening a port.",
    args = "(strPortName='')",
    childs = {
        bCD = {
            type="value",
            description="(Read Only) The current status of the CD line."
        },
        bCTS = {
            type="value",
            description="(Read Only) The current status of the CTS line."
        }, 
        bDSR = {
            type="value",
            description="(Read Only) The current status of the DSR line."
        },
        bIsOpen = {
            type="value",
            description="(Read Only) Contains true if the port is open, false otherwise."
        },
        bRI = {
            type="value",
            description="(Read Only) The current status of the RI line."
        },
        eDataBits = {
            type="value",
            description="Number of data bits. Can be one of the DATABITS_x constants. Default is DATABITS_8."
        },
        eFlowControl = {
            type="value",
            description="Flow control mode. Can be one of the FLOWCONTROL_x constants. Default is FLOWCONTROL_NONE."
        },
        eParity = {
            type="value",
            description="Parity type. Can be one of the PARITY_x constants. Default is PARITY_NONE."
        },
        eStopBits = {
            type="value",
            description="Number of stop bits. Can be one of the STOPBITS_x constants. Default is STOPBITS_1."
        },
        nBaudRate = {
            type="value",
            description="Buad rate of the port. Default is 9600."
        },
        nBytesAvailable = {
            type="value",
            description="(Read Only) Number of bytes available for reading."
        },
        nTimeOutMs = {
            type="value",
            description="Time out for blocking operations in milliseconds. 0 (default) means infinite."
        },
        strPort = {
            type="value",
            description="The name of the COM port, usually 'COMx' in Windows, or the name of the device in Mac OS."
        },
        bWaitForChange = {
            type="function",
            description="Blocks until CTS, DSR, RI, or CD changes, or until a time out occurs. Returns true if one of the lines changed, false if timed out.",
            args = "()",
            returns = "(bResult)"
        },
        nWrite = {
            type="function",
            description="Writes the contents of the string strData to the port. Returns number of bytes written.",
            args = "(strData)",
            returns = "(nBytesWritten)"
        },
        strRead = {
            type="function",
            description="Returns the contents of the read buffer as a string, but only up to nMaxChars bytes.",
            args = "(nMaxChars = 65536)",
            returns = "(strBufferContent)"
        },
        strReadLine = {
            type="function",
            description="Returns the contents of the read buffer as a string, but only up to nMaxChars bytes, or the first newline character, whichever comes first.",
            args = "(nMaxChars = 65536)",
            returns = "(strBufferContent)"
        },
        Flush = {
            type="function",
            description="Flushes both input and output buffers.",
            args = "()",
            returns = "()"
        },
        FlushInput = {
            type="function",
            description="Flushes the input buffer.",
            args = "()",
            returns = "()"
        },
        FlushOutput = {
            type="function",
            description="Flushes the output buffer.",
            args = "()",
            returns = "()"
        },
        Open = {
            type="function",
            description="Attempts to open the port with the current settings. Check the value of the bIsOpen property to see whether the operation was successful.",
            args = "()",
            returns = "()"
        },
        SendBreak = {
            type="function",
            description="Sends the RS-232 break signal (zero bytes) for the specified duration (in bytes). If nDuration is zero, sends a break between 0.25 and 0.5 seconds.",
            args = "(nDuration)",
            returns = "()"
        },
        SetBreak = {
            type="function",
            description="Sets the break condition to the given level.",
            args = "(bLevel = true)",
            returns = "()"
        },
        SetRTS = {
            type="function",
            description="Sets the RTS handshaking line to the given level.",
            args = "(bLevel = true)",
            returns = "()"
        },
        SetDTR = {
            type="function",
            description="Sets the DTR handshaking line to the given level.",
            args = "(bLevel = true)",
            returns = "()"
        }
    }
}

-- DLP/SLA Prototype Specific

local SliceDisplay = {
    type = "class",
    description = "This class provides access to a secondary full-screen window, which can be placed on any monitor, and which can re-sample, filter, and display density slices as black & white images. Since the slice display is a singleton, the constructor always returns the same object. The secondary window will be placed on screen number iScreen.",
    args = "(iScreen)",
    childs = {
        bPrepareSlice = {
            type= "function",
            description = "Prepares the provided slice for display. This includes resampling from the printer's voxel resolution (print volume voxels per unit) to the optical resolution (screen size in pixels), and filtering from a grayscale image to a black & white image, by placing the threshold at 0.5, or 50% density. The function returns true, if the processed slice contains any white pixels, false otherwise. This fact can be used to stop the print once an empty slice is reached.",
            args = "(Hy.DensitySlice oSlice)",
            returns = "(bSuccess)"
        },
        bSaveSlice = {
            type= "function",
            description = "Saves the prepared slice (not the one being displayed!). So the usage is as follows:\nPrepareSlice(…)\nbSaveSlice(…)\nDisplaySlice(…)\nThe optional format parameter can be used to specify the image format. Supported formats are “BMP”, “JPG” and “PNG”, with “PNG” being the default. The function returns true on success, false on failure.",
            args = "(filename [, format])",
            returns = "(bSuccess)"
        },
        bLoadSlice = {
            type= "function",
            description = "Loads a slice, replacing any previously prepared one. No further processing will be applied to the loaded slice, not even scaling to screen size, so that the pixels are guaranteed to be shown 1:1. Like bSaveSlice, bLoadSlice returns true on success, false on failure.",
            args = "(filename)",
            returns = "(bSuccess)"
        },
        DisplaySlice = {
            type= "function",
            description = "Displays a previously prepared slice for the specified number of milliseconds. The function blocks only as long as a previous slice is still being displayed, then returns immediately once the current slice appears on screen. This behavior can be exploited by displaying a slice, then preparing the next one while the first is still being displayed. It also allows the driver to issue commands via the COM port while the slice is on screen.",
            args = "(nMilliseconds)",
            returns = "()"
        },
        WaitForBlank = {
            type= "function",
            description = "Waits until the slice display finishes displaying the current slice, and the screen goes blank. After this call, it is guaranteed that DisplaySlice() will not block.",
            args = "()",
            returns = "()"
        }
    }
}

local Hy = {
    type = "lib",
    description = "The Hy namespace contains properties relevant to the current instance of the running Lua script, and a couple of utility methods.",
    childs = {
        bAbort = {
            type = "value",
            description = "(Read Only) Contains true if the Lua script should abort its operation. You should check this flag periodically, especially during lenghty operations."
        },
        oProject = {
            type = "value",
            valuetype = "Hy.Project",
            description = "(Read Only) Contains an instance of the Hy.Project class, which represents the current project. Projects are shown as tabs in the user interface."
        },
        DisplayProgress = {
            type = "function",
            description = "This method allows the Lua script to display progress information during long operations. The second argument should increase from 0 to 1, with 1 indicating task completion.",
            args = "(strName, dProgress)",
            returns = "()"
        },
        Sleep = {
            type = "function",
            description = "This method suspends the script for the specified number of milliseconds, with the timing precision being dependent on the underlying OS.",
            args = "(nMilliseconds)",
            returns = "()"
        },
        Yield = {
            type = "function",
            description = "Equivalent to Hy.Sleep(0), i.e. sleep for the shortest possible time, allowing other threads to run. It's recommended to use this method in tight loops, when waiting for something to occur.",
            args = "()",
            returns = "()"
        },
        Project = Project,
        Material = Material,
        Printer = Printer,
        DensityField = DensityField,
        DensitySlice = DensitySlice,
        Box = Box,
        Rect = Rect,
        VoxelSize = VoxelSize,
        SliceDisplay = SliceDisplay
    }
}

return {
    Hy = Hy,
    RS232 = RS232
}