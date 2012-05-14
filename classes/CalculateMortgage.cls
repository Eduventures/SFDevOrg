global class CalculateMortgage implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
    
        Decimal anAmount = (Decimal) request.inputParameters.get('Amount');    
        Decimal aTerm= (Decimal) request.inputParameters.get('Term');
        Map<String,Object> result = new Map<String,Object>();
        result.put('MonthlyAmount',5000);
        return new Process.PluginResult(result);
    }

    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('Amount',
            Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('Term',
            Process.PluginDescribeResult.ParameterType.DECIMAL, false)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('MonthlyAmount',
            Process.PluginDescribeResult.ParameterType.DECIMAL)
            };
        return result;
    }
}