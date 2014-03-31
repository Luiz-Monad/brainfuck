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
>+++++++++[<+++++++++++>-]<[>[-]>[-]<<[>+>+<<-]>>[<<+>>-]>>>
[-]<<<+++++++++<[>>>+<<[>+>[-]<<-]>[<+>-]>[<<++++++++++>>>+<
-]<<-<-]+++++++++>[<->-]>>+>[<[-]<<+>>>-]>[-]+<<[>+>-<<-]<<<
[>>+>+<<<-]>>>[<<<+>>>-]>[<+>-]<<-[>[-]<[-]]>>+<[>[-]<-]<+++
+++++[<++++++<++++++>>-]>>>[>+>+<<-]>>[<<+>>-]<[<<<<<.>>>>>-
]<<<<<<.>>[-]>[-]++++[<++++++++>-]<.>++++[<++++++++>-]<++.>+
++++[<+++++++++>-]<.><+++++..--------.-------.>>[>>+>+<<<-]>
>>[<<<+>>>-]<[<<<<++++++++++++++.>>>>-]<<<<[-]>++++[<+++++++
+>-]<.>+++++++++[<+++++++++>-]<--.---------.>+++++++[<------
---->-]<.>++++++[<+++++++++++>-]<.+++..+++++++++++++.>++++++
++[<---------->-]<--.>+++++++++[<+++++++++>-]<--.-.>++++++++
[<---------->-]<++.>++++++++[<++++++++++>-]<++++.-----------
-.---.>+++++++[<---------->-]<+.>++++++++[<+++++++++++>-]<-.
>++[<----------->-]<.+++++++++++..>+++++++++[<---------->-]<
-----.---.>>>[>+>+<<-]>>[<<+>>-]<[<<<<<.>>>>>-]<<<<<<.>>>+++
+[<++++++>-]<--.>++++[<++++++++>-]<++.>+++++[<+++++++++>-]<.
><+++++..--------.-------.>>[>>+>+<<<-]>>>[<<<+>>>-]<[<<<<++
++++++++++++.>>>>-]<<<<[-]>++++[<++++++++>-]<.>+++++++++[<++
+++++++>-]<--.---------.>+++++++[<---------->-]<.>++++++[<++
+++++++++>-]<.+++..+++++++++++++.>++++++++++[<---------->-]<
-.---.>+++++++[<++++++++++>-]<++++.+++++++++++++.++++++++++.
------.>+++++++[<---------->-]<+.>++++++++[<++++++++++>-]<-.
-.---------.>+++++++[<---------->-]<+.>+++++++[<++++++++++>-
]<--.+++++++++++.++++++++.---------.>++++++++[<---------->-]
<++.>+++++[<+++++++++++++>-]<.+++++++++++++.----------.>++++
+++[<---------->-]<++.>++++++++[<++++++++++>-]<.>+++[<----->
-]<.>+++[<++++++>-]<..>+++++++++[<--------->-]<--.>+++++++[<
++++++++++>-]<+++.+++++++++++.>++++++++[<----------->-]<++++
.>+++++[<+++++++++++++>-]<.>+++[<++++++>-]<-.---.++++++.----
---.----------.>++++++++[<----------->-]<+.---.[-]<<<->[-]>[
-]<<[>+>+<<-]>>[<<+>>-]>>>[-]<<<+++++++++<[>>>+<<[>+>[-]<<-]
>[<+>-]>[<<++++++++++>>>+<-]<<-<-]+++++++++>[<->-]>>+>[<[-]<
<+>>>-]>[-]+<<[>+>-<<-]<<<[>>+>+<<<-]>>>[<<<+>>>-]<>>[<+>-]<
<-[>[-]<[-]]>>+<[>[-]<-]<++++++++[<++++++<++++++>>-]>>>[>+>+
<<-]>>[<<+>>-]<[<<<<<.>>>>>-]<<<<<<.>>[-]>[-]++++[<++++++++>
-]<.>++++[<++++++++>-]<++.>+++++[<+++++++++>-]<.><+++++..---
-----.-------.>>[>>+>+<<<-]>>>[<<<+>>>-]<[<<<<++++++++++++++
.>>>>-]<<<<[-]>++++[<++++++++>-]<.>+++++++++[<+++++++++>-]<-
-.---------.>+++++++[<---------->-]<.>++++++[<+++++++++++>-]
<.+++..+++++++++++++.>++++++++[<---------->-]<--.>+++++++++[
<+++++++++>-]<--.-.>++++++++[<---------->-]<++.>++++++++[<++
++++++++>-]<++++.------------.---.>+++++++[<---------->-]<+.
>++++++++[<+++++++++++>-]<-.>++[<----------->-]<.+++++++++++
..>+++++++++[<---------->-]<-----.---.+++.---.[-]<<<]

' AS VARBINARY(MAX));

WITH BF(K, PC, Skip, Stack, Head, Tape, Input, Output)
AS
(
		SELECT 
			K = 0,
			PC = 1,
			Skip = 0,
			Stack = CAST(0x00000000 AS VARBINARY(MAX)),
			Head = 1,
			Tape = CAST(0x00000000 AS VARBINARY(MAX)),
			Input = CAST(0x00000000 AS VARBINARY(MAX)),
			Output = ''
	UNION ALL
		SELECT 
			K = K + 1,
			PC = PC + 1,
			Skip,
			Stack,
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
			Stack = CAST(CAST(PC AS VARBINARY(4)) + Stack AS VARBINARY(MAX)),
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
			Head,
			Tape,
			Input = SUBSTRING(@Input, PC, 1), 
			Output = ''
		FROM
			BF
		WHERE
				Skip = 0
			AND
				LEFT(Input, 1) NOT IN ('>', '<', '+', '-', '.', ',', '[', ']')
)
--SELECT K, PC, Skip, Stack, Head, Tape, Input = CAST(Input AS VARCHAR), Output
SELECT Output
FROM BF 
WHERE LEN(Output) > 0
OPTION ( MAXRECURSION 0 );
