WITH RECURSIVE
var_Input AS (
	SELECT '
++++++++++[>++++++++>+++++++++++
>---------->+++>++++++++>+++++++
+++++>+++++++++++>++++++++++>+++
++++++++>+++<<<<<<<<<<-]>-.>--.>
++++.>++.>---.>---.>.>.>+.>+++.,
'::TEXT::BYTEA AS v
)
,
BF(K, PC, Skip, Stack, Head, Tape, Input, Output)
AS
(
		SELECT 
			0 AS K,
			1 AS PC,
			0 AS Skip,
			('x'||'00000000')::BYTEA AS Stack,
			1 AS Head,
			('x'||'00000000')::BYTEA AS Tape,
			('x'||'00000000')::BYTEA AS Input,
			'' AS Output
	UNION ALL
		SELECT
			K + 1 AS K,
			(CASE WHEN 
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = ']'
			THEN
				SUBSTRING(Stack, 1, 4)::BIT(32)::INT
			ELSE			
				PC + 1 
			END) AS PC,
			(CASE WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '['
				AND
					SUBSTRING(Tape, Head, 4)::BIT(32)::INT = 0
			THEN
				LENGTH(Stack)::INT
			WHEN
					Skip != 0
				AND
					SUBSTRING(Input, 1, 1) = '['
			THEN
				Skip + 4 
			WHEN
					Skip != 0
				AND
					SUBSTRING(Input, 1, 1) = ']'
				AND
					LENGTH(Stack) < Skip
			THEN
				Skip - 4
			WHEN
					Skip != 0
				AND
					SUBSTRING(Input, 1, 1) = ']'
				AND
					LENGTH(Stack) = Skip
			THEN
				0
			ELSE
				Skip
			END) AS Skip,
			(CASE WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '['
				AND
					SUBSTRING(Tape, Head, 4)::BIT(32)::INT != 0
			THEN
				PC::BIT(32)::TEXT::BYTEA || Stack
			WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = ']'
			THEN
				SUBSTRING(Stack, 5, LENGTH(Stack) - 4)
			ELSE 
				Stack
			END) AS Stack,
			(CASE WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '<'
			THEN
				Head - 4
			WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '>'
			THEN
				Head + 4				
			ELSE
				Head
			END) AS Head, 
			(CASE WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '>'
				AND
					Head + 4 > LENGTH(Tape)
			THEN
				Tape || '\\x00000000'::BYTEA
			WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '+'
			THEN
				(SUBSTRING(Tape, Head, 4)::BIT(32)::INT + 1)::BIT(32)::TEXT::BYTEA
				 || SUBSTRING(Tape, Head + 4, LENGTH(Tape) - Head)
			WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '-'
			THEN
				(SUBSTRING(Tape, Head, 4)::BIT(32)::INT - 1)::BIT(32)::TEXT::BYTEA
				 || SUBSTRING(Tape, Head + 4, LENGTH(Tape) - Head)
			ELSE
				Tape
			END) AS Tape,
			(CASE WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = ']'
			THEN
				SUBSTRING((SELECT v FROM var_Input), SUBSTRING(Stack, 1, 4)::BIT(32)::INT - 1, 1)
			ELSE
				SUBSTRING((SELECT v FROM var_Input), PC, 1)
			END) AS Input, 
			(CASE WHEN
					Skip = 0
				AND
					SUBSTRING(Input, 1, 1) = '.'
			THEN
				SUBSTRING(Tape, Head, 4) 
			ELSE
				''
			END) AS Output
		FROM
			BF
        WHERE
            K < 200			
)
SELECT Output
FROM BF 

;

