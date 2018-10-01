/*
* Class to manage method definition for Complex expressions
*/
public class ComplexMethod {
    public static map<string, methodDefinition> methodDefMap = new map<string, methodDefinition>{
        'AND' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'BOOLEAN','METHOD'}},'BOOLEAN'),
            'OR' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'BOOLEAN','METHOD'}},'BOOLEAN'),
            'NOT' => new methodDefinition(2, -1, new map<integer, set<string>>{-1=> new set<string>{'BOOLEAN','METHOD'}},'BOOLEAN'),
            'EQUALS' => new methodDefinition(2, 2, new map<integer, set<string>>{-1 => new set<string>{'ANY','METHOD'}},'BOOLEAN'),
            'INCLUDES' => new methodDefinition(2, 2, new map<integer, set<string>>{1=> new set<string>{'FIELDREFERENCE'}, 2=>new set<string>{'FIELDREFERENCE','STRING','METHOD'}},'BOOLEAN'),
            // Count params: String: Reference field, String subquery aside from reference match
            'COUNT' => new methodDefinition(2, 2, new map<integer, set<string>>{1=> new set<string>{'FIELDREFERENCE'}, 2=>new set<string>{'STRING'}},'INTEGER'),
            // Coount Reference params: String: Reference/key match field on current object, String: Referenced sObject followed by reference field, String subquery aside from key match match
            'COUNTKEY' => new methodDefinition(3, 3, new map<integer, set<string>>{1=> new set<string>{'FIELDREFERENCE'}, 2=>new set<string>{'FIELDREFERENCE'}, 3=>new set<string>{'STRING'}},'INTEGER'),
            // Count Distinct params: String: Reference field, String subquery aside from reference match, String Reference field
            'COUNTDISTINCT' => new methodDefinition(3, 3, new map<integer, set<string>>{1=> new set<string>{'FIELDREFERENCE'}, 2=>new set<string>{'STRING'}, 3=> new set<string>{'FIELDREFERENCE'}},'INTEGER'),
            // Coount Reference params: String: Reference/key match field on current object, String: Referenced sObject followed by reference field, String subquery aside from key match match
            'COUNTKEYDISTINCT' => new methodDefinition(4, 4, new map<integer, set<string>>{1=> new set<string>{'FIELDREFERENCE'}, 2=>new set<string>{'FIELDREFERENCE'}, 3=>new set<string>{'STRING'}, 4=> new set<string>{'FIELDREFERENCE'}},'INTEGER'),
            'TODAY' => new methodDefinition(0, 0, new map<integer, set<string>>{},'DATE'),
            'NOW' => new methodDefinition(0, 0, new map<integer, set<string>>{},'DATETIME'),
            'YEAR' => new methodDefinition(1, 1, new map<integer, set<string>>{1 => new set<string>{'DATE','DATETIME','METHOD'}},'INTEGER'),
            'MONTH' => new methodDefinition(1, 1, new map<integer, set<string>>{1 => new set<string>{'DATE','DATETIME','METHOD'}},'INTEGER'),
            'DAY' => new methodDefinition(1, 1, new map<integer, set<string>>{1 => new set<string>{'DATE','DATETIME','METHOD'}},'INTEGER'),
            'CASE' => new methodDefinition(4, -1, new map<integer, set<string>>{-1 => new set<string>{'ANY','METHOD'}},'ANY', 2),
            'ADD' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'NUMERIC','METHOD'}},'NUMERIC'),
            'SUBTRACT' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'NUMERIC','METHOD'}},'NUMERIC'),
            'MULTIPLY' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'NUMERIC','METHOD'}},'NUMERIC'),
            'DIVIDE' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'NUMERIC','METHOD'}},'NUMERIC'),
            'CONCAT' => new methodDefinition(2, -1, new map<integer, set<string>>{-1 => new set<string>{'STRING','METHOD'}},'STRING'),
            'SEQAULS' => new methodDefinition(2, 2, new map<integer, set<string>>{-1 => new set<string>{'ANY','METHOD'}},'BOOLEAN'),
            'LEQAULS' => new methodDefinition(2, 2, new map<integer, set<string>>{-1 => new set<string>{'ANY','METHOD'}},'BOOLEAN'),
            'LARGER' => new methodDefinition(2, 2, new map<integer, set<string>>{-1 => new set<string>{'ANY','METHOD'}},'BOOLEAN'),
            'SMALLER' => new methodDefinition(2, 2, new map<integer, set<string>>{-1 => new set<string>{'ANY','METHOD'}},'BOOLEAN')
            };
                
                public class methodDefinition {
                    public integer min{get;set;}
                    public integer max{get;set;}
                    public integer multipleOf {get;set;}
                    public string returnType{get;set;}
                    public map<integer,set<string>> types {get;set;}
                    public methodDefinition(integer min, integer max, map<integer,set<string>> typeMap, string returnType){
                        this(min, max, typeMap, returnType, null);
                    }
                    public methodDefinition(integer min, integer max, map<integer,set<string>> typeMap, string returnType, integer multipleOf){
                        this.min = min;
                        this.max = max;
                        this.types = typeMap;
                        this.returnType = returnType;
                        this.multipleOf = multipleOf;
                    }
                }
    
}