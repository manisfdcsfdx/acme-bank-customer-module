public with sharing class GenerateUniqueIdentifier {

    public static string getString(Integer length) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        return generateIdentifier(chars,length);
    }
    public static string getNumeric(Integer length) {
        String chars = '0123456789';
        return generateIdentifier(chars,length);
    }
    public static string getAplaNumeric(Integer length) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        return generateIdentifier(chars,length);
    }
    private static string generateIdentifier(string chars, Integer length){
        String result = '';
        while (result.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            result += chars.substring(idx, idx+1);
        }
        return result;
    }
}
