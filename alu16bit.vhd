LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
------------	SIGNAL INVERT / AINVERT ------------
entity aInvert1 is
	port (a , s :in std_logic;
			f : out std_logic);
end aInvert1;

architecture aInvertf of aInvert1 is  -- f gia function
	begin
		process(a ,s)
			begin
				if s = '0' then
					f <= a;
				else 
					f <= not a;
				end if;
		end process;
end aInvertf;


------------ FULL ADDER CIRCUIT	-------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
entity fullAdder is
	port (a, b, carryIn :in std_logic;
				sum, carryOut :out std_logic);
end fullAdder;

architecture fullAdderf of fullAdder is
	begin
		sum <= (a and not b and not carryIn) or (not a and b and not carryIn) or (not a and not b and carryIn) or (a and b and carryIn);  --ulopoihsh athroismatos
		carryOut <= (a and b) or (a and carryIn) or (b and carryIn);	--ulopoihsh kratoumenou (dosmenoi typoi)
end fullAdderf;


----------- 1 BIT BASIC CIRCUIT ------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
entity basic_circ is
	port(a, b, carryIn, AInvert, BInvert: in std_logic;
			carryOut, result: out std_logic;
			selector: in std_logic_vector(1 downto 0));	
end basic_circ;

architecture basic_circf of basic_circ is
	
	component aInvert1 is
		port (a, s : in std_logic ;
					f  : out std_logic);
	end component aInvert1;
	component fullAdder is
		port (a, b, carryIn : in std_logic;
					sum, carryOut : out std_logic);
	end component fullAdder;
	
	signal n1, n2, sum : std_logic;
	
	begin
		invert1: aInvert1 port map (a => a, s => AInvert, f => n1);  -- ainvert output
		binvert1: aInvert1 port map (a=> b, s => BInvert, f => n2);		-- binvert output
		adder: fullAdder port map (a => a, b => b, carryIn => carryIn, sum => sum, carryOut => carryOut);  --full adder output
		-- exoume merika apo ta shmata poy xreiazomaste, prepei apla analoga to selector na epilejoume thn antistoixh prajh
		
		with selector select
				result <= a and b when "00",
				a or b when "01",
				sum when "10",
				a xor b when others;
		
end basic_circf;

-------------- CONTROL CIRCUIT ---------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
entity controlCircuit is  -- analoga me to opcode ektelountai oi antistoixes prajeis
	port( opcode : in std_logic_vector(2 downto 0);
			operation : out std_logic_vector(1 downto 0);
			ainvert, binvert, cin: out std_logic);
end controlCircuit;

architecture controlCircuitf of controlCircuit is
	begin 
		process(opcode)
			begin 
					if opcode = "000" then	-- AND
					  operation <= "00";
					  ainvert   <= '0';
					  binvert      <= '0';
					  cin  <= '0';
					elsif opcode = "001" then 	-- OR
					  operation <= "01";
					  ainvert   <= '0';
					  binvert     <= '0';
					  cin  <= '0';
					elsif opcode = "010" then	-- ADD
					  operation <= "10";
					  ainvert   <= '0';
					  binvert      <= '0';
					  cin  <= '0';
					elsif opcode = "011" then	-- SUB
					  operation <= "10";
					  ainvert   <= '0';
					  biNvert      <='1';
					  cin  <= '1';
					elsif opcode = "100" then	-- NOR
					  operation <= "00";
					  ainvert   <= '1';
					  binvert      <= '1';
					  cin  <= '0';  
					elsif opcode = "101" then	-- NAND 
					  operation <= "01";
					  ainvert   <= '1';
					  binvert      <= '1';
					  cin  <= '0';
					elsif opcode =  "110" then	-- XOR
					  operation <= "11";
					  ainvert   <= '0';
					  binvert      <= '0';
					  cin  <= '0';
				end if; 
		end process;
end controlCircuitf;
				
----------------- 16 BIT ALU -------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
entity alu16bit is
	port (num1, num2: in std_logic_vector(15 downto 0);
			opcode : in std_logic_vector(2 downto 0);
			result : out std_logic_vector(15 downto 0);
			overflow : out std_logic);
end alu16bit;

architecture alu16bitf of alu16bit is
	component basic_circ is  
		port(a, b, carryIn, AInvert, BInvert: in std_logic;
			carryOut, result: out std_logic;
			selector: in std_logic_vector(1 downto 0));	
	end component basic_circ;
	
	component controlCircuit is
		port( opcode : in std_logic_vector(2 downto 0);
			operation : out std_logic_vector(1 downto 0);
			ainvert, binvert, cin: out std_logic);
	end component controlCircuit;
	signal ainvert,binvert : std_logic;
	signal carry_transfer : std_logic_vector(16 downto 0);
	signal operation : std_logic_vector(1 downto 0);
	
	begin

	cc: controlCircuit port map (opcode => opcode, ainvert => ainvert, binvert => binvert, 
	cin => carry_transfer(0),  operation => operation);
	
	mainLoop: for i in 0 to 15 generate
		alu: basic_circ port map (a => num1(i), b => num2(i), selector => operation, carryIn => carry_transfer(i), ainvert => ainvert,
		binvert => binvert, carryout => carry_transfer(i+1), result => result(i));
	end generate;
	overflow <= carry_transfer(16); -- to teleutaio carry poy bghke, ousiastika einai to overflow
	
end alu16bitf;