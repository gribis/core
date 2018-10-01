/*
 * Boolean expression builder element
 * 
 * Purpose: Represents a single functional element of a boolean expression
 * 
 * Supported features:
 * - Value respresentation via
 * 		a) single index reference to a boolean result array
 *   or
 * 		b) Holds a list of sub-elements that are evaluated in a logical AND or 
 *   	   a logical OR fashion, depending on the logical operator
 *   or
 * 		c) A static true or false value
 * - Apply logical NOT to result of expression
*/
public class ComplexElement {
    public class ComplexElementException extends Exception {}
	public integer elementIndex;
    public String Type;
    public boolean logicalAnd = false;
    public boolean logicalNot = false;
    public ComplexElement[] elements;
    public boolean staticResult;
    public object value;
    private boolean result;

    public ComplexElement(integer index, String Type){
        elementIndex = index;
        this.Type = Type;
    }
    public ComplexElement(ComplexElement[] subElements, string Type){
        elements = subElements==null?new ComplexElement[]{}:subElements;
        this.Type = Type;
    }

    // Instantiate simple element
    public ComplexElement(integer index, boolean isNot){
        elementIndex = index;
        logicalNot = isNot==true;
    }
    // Instantiate element with child elements
    public ComplexElement(ComplexElement[] subElements, boolean isAnd, boolean isNot){
        elements = subElements==null?new ComplexElement[]{}:subElements;
        logicalAnd = isAnd==true;
        logicalNot = isNot==true;
    }
    // Instantiate uninitialized element
    public ComplexElement(){}
    public boolean evaluate(list<boolean> resultList) {
        if(resultList==null)
            throw new ComplexElementException(system.label.Expression_Element_No_Result_List);
        if(elementIndex!=null) { // Capture this element value
            if(resultList.size() <= elementIndex-1)
                throw new ComplexElementException(string.format(system.label.Expression_Element_Missing_Result_List_Index, new string[]{elementIndex.format()}));
            result = resultList[elementIndex-1]==true;
        } else if (elements!=null ? !elements.isEmpty() : false) { // Capture sub-elements values applying opereator
            integer i = 0;
            do {
                result = elements[i].evaluate(resultList);
                i++;
            } while(elements.size() > i && (logicalAnd==true ? result==true : result==false));
        } else if (staticResult!=null) {
            result = staticResult;
        } else
            throw new ComplexElementException(system.label.Expression_Element_Missing_Evaluation_Criteria);
        // When logicalNot = false, return true when result is true 
        // When logicalNot = true,  return true when result is false
        return result = result==(logicalNot==false);
    }
    // Return serialized form of strucutre
    public string serialize() {
        return JSON.serialize(this, true);
    }
    
    // Return structure as code
    public string encode(){
        return doEncode(true);
    }
    private string doEncode(boolean isRootElement){
        // Add inversion
        string thisElement = logicalNot==true ? 'NOT ':'';
        // Element is a list
        if(elements!=null) {
            string[] childElements = new string[]{};
            for(ComplexElement e:elements)
                childElements.add(e.doEncode(false));
            thisElement += (isRootElement==true?'':'(')+string.join(childElements, (logicalAnd==true?' AND ':' OR '))+(isRootElement==true?'':')');
        // Element is an index
        } else if (elementIndex!=null) {
            thisElement += elementIndex.format();
        // Element is a static value
        } else if (staticResult!=null) {
            thisElement += (staticResult==true?'TRUE':'FALSE');
        } else 
            throw new ComplexElementException(system.label.Expression_Element_Encoding_Missing_Criteria);
        return thisElement;
    }
}