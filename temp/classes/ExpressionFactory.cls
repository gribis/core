/*
 * Class to generate 
*/
public class ExpressionFactory {
    public string source {get;set;}
    public string json {get;set;}
    public string rendered {get;private set;}
    public integer maxIndex {get;set;}
    public boolean expressionResult {get;private set;}
    public list<ExpressionParser.Token> tokens {get;set;}
    public ExpressionElement rootElement {get;set;}
    public list<boolean> expressionTestValues {
        get{
            list<boolean> bList = new list<boolean>{};
            if(expressionTest!=null)
                for(checkItem ci: expressionTest)
                	bList.add(ci.selected);
            return bList;
        }
    }
    public list<checkItem> expressionTest {get;set;}
    public class checkItem{
        public checkItem(boolean selected){
            this.selected = selected;
        }
        public boolean selected{get;set;}
    }
    public PageReference parseSource() {
        try {
            // Prepopulate result structure
            if(maxIndex!=null ? maxIndex>0: false){
                if(expressionTest==null)
                    expressionTest = new list<checkItem>{};
                while(expressionTest.size() < maxIndex || expressionTest.size() > maxIndex){
                    if(expressionTest.size() >maxIndex)
                        expressionTest.remove(maxIndex);
                    else
                        expressionTest.add(new checkItem(false));
                }
                
            }
            ExpressionParser ep = new ExpressionParser(source, maxIndex);
        	ExpressionElement e = ep.parse();
            rendered = e.Encode();
            json = e.serialize();
			tokens = ep.tokens;
            expressionResult = e.evaluate(expressionTestValues);
        } catch (ExpressionParser.ExpressionParserException ep){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ep.getMessage(), ep.getDetail()));
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    public PageReference parseJson() {
        try {
            ExpressionElement e = parseJsonExpression(json);
            rendered = e.Encode();
            source = rendered;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }        return null;
    }

    public class ExpressionJsonParseException extends Exception {}
    
    // Parse a JSON string into the ExpressionElement structure
    public static ExpressionElement parseJsonExpression(string jsonString) {
        ExpressionElement ee;
        try {
	        ee = (ExpressionElement)JSON.deserializeStrict(jsonString, ExpressionElement.class);
        } catch(Exception e) {
            throw new ExpressionJsonParseException('Unable to parse the provided JSON string into an expression structure.', e);
        }
        return ee;
    }
    
    // Parse logical expression string into structure
    // Supported syntax:
    // - numeric index value
    // - logical concatenation conditions (AND, &&, OR, &&)
    // - grouping operator "(", ")"; must have equal number of open "(" and close ")" operators
    // 		Within one grouping, logical concatenation operators (AND, OR) must be consitent
    // 		e.g. 1 AND 2 AND 3 is correct
    // 		e.g. 1 AND 2 OR 3 is NOT correct and will cause a compilation error.
    // - Logical negation operator (NOT, !) reverse the boolean outcome of the applicable result
    // 		a) Negators can be applied to groups as follows
    // 			NOT(1 OR 2)
    // 			!(1 AND 2)
    // 	 	b) Similarly, negation operators can be applied to specific values directly
    // 			!1
    // 			NOT 1
    public static ExpressionElement parseLogicalString(string logicalString, integer maximumElementIndex) {
        
        // Vocabulary: AND, OR, NOT, &&, ||, !, \d, true, false, \(, \)
        ExpressionParser ep = new ExpressionParser(logicalString, maximumElementIndex);
        return ep.parse();
    }
    
}