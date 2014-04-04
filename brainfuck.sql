/*	
>  becomes  ++p; 
<  becomes  --p; 
+  becomes  ++*p; 
-  becomes  --*p; 
.  becomes  putchar(*p); 
,  becomes  *p = getchar(); 
[  becomes  while (*p) { 
]  becomes  } 
*/

DECLARE @Input VARBINARY(MAX) 
SELECT @Input = CAST('
++++++++++[>++++++++>+++++++++++
>---------->+++>++++++++>+++++++
+++++>+++++++++++>++++++++++>+++
++++++++>+++<<<<<<<<<<-]>-.>--.>
++++.>++.>---.>---.>.>.>+.>+++.,
' AS VARBINARY(MAX));

DECLARE @Data VARBINARY(MAX) 
SELECT @Data = CAST('
0
' AS VARBINARY(MAX));

WITH BF(K, PC, Skip, Stack, DC, Head, Tape, Input, Output)
AS
(
		SELECT 
			K = 0,
			PC = 1,
			Skip = 0,
			Stack = CAST(0x00000000 AS VARBINARY(MAX)),
			DC = 1,
			Head = 1,
			Tape = CAST(0x00000000 AS VARBINARY(MAX)),
			Input = CAST(0x30 AS VARBINARY(MAX)),
			Output = ''
	UNION ALL
		SELECT 
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head = Head - 4, 
			Tape, 
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '<'
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head = Head + 4, 
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '>'
			AND
				Head + 4 <= DATALENGTH(Tape)
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head = Head + 4, 
			Tape = CAST(Tape + 0x00000000 AS VARBINARY(MAX)), 
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '>'	
			AND
				Head + 4 > DATALENGTH(Tape)
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head,
			Tape = (
				SUBSTRING(Tape, 0, Head) + 
				CAST(CAST(SUBSTRING(Tape, Head, 4) AS INT) + 1 AS VARBINARY(4)) + 
				SUBSTRING(Tape, Head + 4, LEN(Tape) - Head)),
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '+'
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head,
			Tape = (
				SUBSTRING(Tape, 0, Head) + 
				CAST(CAST(SUBSTRING(Tape, Head, 4) AS INT) - 1 AS VARBINARY(4)) + 
				SUBSTRING(Tape, Head + 4, LEN(Tape) - Head)),
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '-'
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = CAST(CAST(CAST(SUBSTRING(Tape, Head, 4) AS INT) AS VARBINARY(1)) AS CHAR(1))
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '.'
	UNION ALL
		SELECT 
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC = DC + 1,
			Head, 
			Tape = (
				SUBSTRING(Tape, 0, Head) + 
				CAST(CAST(SUBSTRING(@Data, DC, 1) AS INT) AS VARBINARY(4)) + 
				SUBSTRING(Tape, Head + 4, LEN(Tape) - Head)),
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = ','
			AND
				DC <= DATALENGTH(@Data)	
	UNION ALL
		SELECT 
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head, 
			Tape = (
				SUBSTRING(Tape, 0, Head) + 
				CAST(CAST(0 AS INT) AS VARBINARY(4)) + 
				SUBSTRING(Tape, Head + 4, LEN(Tape) - Head)),
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = ','
			AND
				DC > DATALENGTH(@Data)					
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack = CAST(CAST(PC AS VARBINARY(4)) + Stack AS VARBINARY(MAX)),
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '['
			AND
				CAST(SUBSTRING(Tape, Head, 4) AS INT) != 0	
	UNION ALL
		SELECT
			K = K + 1,
			PC = CAST(SUBSTRING(Stack, 1, 4) AS INT),
			Skip,
			Stack = SUBSTRING(Stack, 5, LEN(Stack) - 4),
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, CAST(SUBSTRING(Stack, 1, 4) AS INT) - 1, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = ']'	
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip = CAST(DATALENGTH(Stack) AS INT),
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) = '['
			AND
				CAST(SUBSTRING(Tape, Head, 4) AS INT) = 0
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip != 0
			AND
				LEFT(Input, 1) NOT IN ('[', ']')
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip = Skip + 4,
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip != 0
			AND
				LEFT(Input, 1) = '['					
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip = Skip - 4,
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip != 0
			AND
				LEFT(Input, 1) = ']'
			AND
				LEN(Stack) < Skip					
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip = 0,
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip != 0
			AND
				LEFT(Input, 1) = ']'
			AND
				LEN(Stack) = Skip
	UNION ALL
		SELECT
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
			DC,
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) NOT IN ('>', '<', '+', '-', '.', ',', '[', ']', '')
)
--SELECT K, PC, Skip, Stack, DC, Head, Tape, Input = CAST(Input AS VARCHAR), Output
SELECT Output
FROM BF 
WHERE LEN(Output) > 0
OPTION ( MAXRECURSION 0 );
