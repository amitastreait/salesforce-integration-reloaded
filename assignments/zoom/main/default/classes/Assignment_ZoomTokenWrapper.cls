/**
 * @description       : 
 * @author            : Amit Singh - PantherSchools
 * @group             : 
 * @last modified on  : 03-30-2024
 * @last modified by  : Amit Singh - PantherSchools
**/
public with sharing class Assignment_ZoomTokenWrapper {
    public String access_token;
    public Integer expires_in;
    public String refresh_token;
    public String scope;
    public String token_type;

    String json = '{'+
        '    "access_token": "ya29.a0AfB_byBo1r2g-xfChwfXNhc48YQfjGCyUk305ccU31pj82SgitiIbqLz9jF-h933Ta3KYYUmmvah38s6RRncN7TK5raYiotagVeB-jBSiJQ92k0gHHePpnAXygziO8cLbNjVlMCP4YAN_pqTJXYqp6K49hRPcMHWesQwaCgYKAU4SARESFQHGX2MiRPFRq5ZvHDEbKIxpxIQqJA0171",'+
        '    "expires_in": 3599,'+
        '    "refresh_token": "1//0g_rdBGeucFejCgYIARAAGBASNwF-L9Ir9CCffstEMPRsjErsDjPc8GPz_OvLKSBsYkh27W1e0h2z9t--1yf5E-OqSzYkjLqlzwU",'+
        '    "scope": "https://www.googleapis.com/auth/drive.metadata.readonly",'+
        '    "token_type": "Bearer"'+
    '}';
}