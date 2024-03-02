--[[ The Program ]]
local Program Program = {
	--[[ The Program's (Local) Variables ]]
	Locals		=	{
						Username	=	os.getenv("USERNAME") or "User",	-- Name of currently logged in user
						Admin		=	true,								-- Show "C:\Windows\system32" instead of "C:\Users\Name" when true
						LastInput	=	{									-- Internal Command Handler Stuff
											String	=	nil,
											Table	=	nil,
											Command	=	nil,
										},
					},
	--[[ The Program's (Local) (Internal) Functions ]]
	Functions	=	{
						string_gmatch		=	string.gmatch,
						Split				=	function(inputstr, sep)
													if not inputstr then return end
													if sep == nil then sep = "%s" end local t,i={},0
													for str in Program.Functions.string_gmatch(inputstr, "([^"..sep.."]+)") do i=i+1 t[i]=str end
												return t end,
						string_format		=	string.format,
						io_read				=	io.read,
						io_write			=	io.write,
						os_execute			=	os.execute,
						Print				=	print,
						PrintInitialHeader	=	function()
													Program.Functions.io_write("Microsoft Windows [Version 10.0.17763.1637]\n(c) 2018 Microsoft Corporation. All rights reserved.")
												end,
						PrintNewLineAdmin	=	function()
													Program.Functions.io_write("\nC:\\Windows\\system32>")
												end,
						PrintNewLineUser	=	function()
													Program.Functions.io_write(Program.Functions.string_format("\nC:\\Users\\%s>", Program.Locals.Username))
												end,
						table_remove		=	table.remove,
						table_concat		=	table.concat,
						string_lower		=	string.lower,
						string_match		=	string.match,
						StringBlank			=	function(inputstr)
													return not (Program.Functions.string_match(inputstr, "%S") ~= nil)
												end,
					},
	--[[ The Program's Initialization/Startup Function ]]
	Init		=	function()
						if Program.Locals.Admin then
							Program.Functions.os_execute("title Administrator: Command Prompt")
						else
							Program.Functions.os_execute("title Command Prompt")
						end
						Program.Functions.os_execute("cls")
						Program.Functions.PrintInitialHeader()
						while true do
							Program.Program()
						end
					end,
	--[[ The Program's Commands (Overrides) ]]
	Commands	=	setmetatable({
						ipconfig	=	function(CommandTable, CommandString)
											local Print = Program.Functions.Print										-- Localize the already local Print function since it will be called multiple times here within this example command
											Print()
											Print("Windows IP Configuration")
											Print()
											Print()
											Print("Wireless LAN adapter Wi-Fi:")
											Print()
											Print("   Media State . . . . . . . . . . . : Media disconnected")
											Print("   Connection-specific DNS Suffix  . :")
											Print()
											Print("Ethernet adapter Bluetooth Network Connection:")
											Print()
											Print("   Media State . . . . . . . . . . . : Media disconnected")
											Print("   Connection-specific DNS Suffix  . :")
											Print()
											Print("Ethernet adapter Ethernet:")
											Print()
											Print("   Media State . . . . . . . . . . . : Media disconnected")
											Print("   Connection-specific DNS Suffix  . :")
										end,
						ifconfig	=	function(CommandTable, CommandString)											-- The Linux equivalent to the Windows "ipconfig" command, "ifconfig"
											Program.Commands.ipconfig(CommandTable, CommandString)						-- Make this "ifconfig" command use our already defined/overridden "ipconfig" command function
										end,
						echo		=	function(CommandTable, CommandString)
											Program.Functions.table_remove(CommandTable, 1)								-- Removes the "echo" command from the command table so that we do not echo the entire command which would include the echo part
											Program.Functions.Print(Program.Functions.table_concat(CommandTable, " "))	-- Print the remainder of what is left in the command table
										end,
						cmd			=	function(CommandTable, CommandString)											-- Catch a call to break out of FakeCMD and into a real CMD (within FakeCMD)
											return																		-- Do nothing but return back to FakeCMD instead
										end,
										sc = function(CommandTable, CommandString)
											local Print = Program.Functions.Print
											local parts = {} -- Extrae el nombre del servicio del comando
											for part in CommandString:gmatch("%S+") do
												table.insert(parts, part)
											end
										
											if #parts >= 3 then
												local service = parts[3]
												local specific_services = {"diagtrack", "sysmain", "pcasvc", "eventlog", "dps", "dusmsvc", "appinfo"}
												local is_specific_service = false
												for _, s in ipairs(specific_services) do
													if service == s then
														is_specific_service = true
														break
													end
												end
												if is_specific_service then
													Print(string.format("NOMBRE_SERVICIO: %s", service))
													Print("        TIPO               : 30  WIN32")
													Print("        ESTADO             : 4  RUNNING")
													Print("                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)")
													Print("        CODIGO_DE_SALIDA_DE_WIN32   : 0  (0x0)")
													Print("        CODIGO_DE_SALIDA_DE_SERVICIO: 0  (0x0)")
													Print("        PUNTO_COMPROB.     : 0x0")
													Print("        INDICACIÓN_INICIO  : 0x0")
												else
													local system_command = "sc query " .. service
													os.execute(system_command)
												end
											else
												Print("Error: No se proporcionó un nombre de servicio válido.")
											end
										end
					},{__index = function(CommandTable, CommandString) return
						function(CommandTable, CommandString)
							if CommandString and not Program.Functions.StringBlank(CommandString) then
								Program.Functions.os_execute(Program.Functions.string_format('(%s)', CommandString))
							end
						end
					end}),
	--[[ The Program's Main/Basic Function/Routine ]]
	Program		=	function()
						if Program.Locals.Admin then				-- If Admin Then
							Program.Functions.PrintNewLineAdmin()	-- Print "C:\Windows\system32"
						else										-- Otherwise If Not Admin Then
							Program.Functions.PrintNewLineUser()	-- Print "C:\Users\Name"
						end
						
						Program.Locals.LastInput.String		=	Program.Functions.io_read() or ""											-- Read the user's input as a string
						Program.Locals.LastInput.Table		=	Program.Functions.Split(Program.Locals.LastInput.String)					-- Convert the user's input to a table for command arguments (for FakeCMD override commands)
						Program.Locals.LastInput.Command	=	Program.Functions.string_lower(Program.Locals.LastInput.Table[1] or "")		-- Force the first part of the user's input command to be in all lowercase, fixing/avoiding the usage of uppercase to bypass FakeCMD override commands
						
						Program.Commands[Program.Locals.LastInput.Command](Program.Locals.LastInput.Table, Program.Locals.LastInput.String)	-- Finally handle the user's input
					end,
}

Program.Init() --Initialize/Start Program