/*
 * Class to validate regular expression syntax in SFDC
*/
public class regexTester {
    public string regexp {get;set;}
    public string compiledString;
    public string result {get;set;}
    public string sampleString {get;set;}
    public string apexEncoded {get;set;}
    public string compiledSample;
    public PageReference Test() {
        // Execute regular expression
        try {
            // Create new compiler object
            Pattern activePattern;
            Matcher activeMatcher;
            if(compiledString != regexp || compiledSample!= sampleString) {
            	activePattern = Pattern.compile(regexp);
                compiledString = regexp;
                apexEncoded = regexp!=null?regexp.replace('\\', '\\\\').replace('\'','\\\''):null;
                compiledSample = sampleString;
                activeMatcher = activePattern.matcher(sampleString);
                result = '';
                integer matchCount = 0;
                while(activeMatcher.find()) {
                    matchCount++;
                    result += 'Found match '+String.valueOf(matchCount)+' ['+string.valueOf(activeMatcher.Start(0))+'-'+string.valueOf(activeMatcher.End(0))+']:'+activeMatcher.group(0)+'\n';
                    for(integer i = 1; i < activeMatcher.groupCount(); i++){
                        result+='-- Subgroup '+String.valueOf(i)+': '+activeMatcher.group(i)+'\n';
                    }
                }
            }
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Oops. Something went wrong. ' +e.getMessage()));
        }
        return null;
    }
}