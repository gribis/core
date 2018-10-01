/*
 * Capture one token element of a complex expression
*/
public class ComplexToken {
	public enum Token {
        // Grouping
        OP_L_PAREN, OP_R_PAREN,OP_L_BRAKET,OP_R_BRAKET, OP_L_BRACE, OP_R_BRACE, 
        // Separaters    
        OP_SEMICOL, OP_PERIOD,  OP_COMA,
        // Math
        OP_MULTI, OP_DIVIS, OP_POWER, OP_ADD, OP_SUB,  OP_INCREMENT, OP_DECREMENT, 
        // Equality
        OP_LESS, OP_GREATER, OP_EQ, OP_LESS_EQ, OP_GREATER_EQ, OP_NOT_EQ, 
        // Logical
        OP_NEGATION, OP_AND, OP_OR, OP_TRUE, OP_FALSE,
        // Assignment operators
        OP_ASSIGN, OP_ASSIGN_ADD, OP_ASSIGN_SUB,
        // Other types
        PRIMARY, METHOD, REFERENCE, EXPRESSION, PARAMETERS, EOF
    }
    
    public enum TokenClass {
        Operator, 		// Grouping or related operators + - * / = etc.
        Separator, 		// Separate elements , . etc.
        Reference,		// Field reference or global variable or local variable
        Method,			// Method reference
        Primary			// Value of numeric or string
    }
    
    public Token type {get;set;}
    public TokenClass tokenClass {get;set;}
    public object value {get;set;}
    public list<ComplexToken> parameters {get;set;}
    public integer startIndex;
    public integer endIndex;
    
    public ComplexToken(string val, TokenClass tc) {
        this.tokenClass = tc;
        this.value = (object)val;
    }
    
    public ComplexToken(Token t, object value) {
        
    }
    
    public ComplexToken(string[] stringTokens) {
        
    }
}