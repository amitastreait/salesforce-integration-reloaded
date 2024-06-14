public class FormulaBuilder {
    public static void evaluate(){
        try{
            FormulaEval.FormulaInstance ff = Formula.builder()
                .withReturnType(FormulaEval.FormulaReturnType.BOOLEAN )
                .withType(Contact.SObjectType)
                .withFormula('Account.Name <> null')
                .build();
            
            BOOLEAN  accountNameBlank = (BOOLEAN )ff.evaluate(
                new Contact(LastName='Test', FirstName='Amit')
            );
            System.debug(accountNameBlank);
        }catch(System.FormulaValidationException ex){
            System.debug(ex.getMessage());
        }catch(System.Exception ex){
            System.debug(ex.getMessage());
        }
    }
}