# The IRIS Toolbox
# X12-ARIMA spec file template used by tseries/x12 function

series {
   data = (
   ## series_data
   )
   period = ## series_period
   start = ## series_start
   precision = 5
   decimals = 5
}

transform {
   function = ## transform_function
}

automdl {
}

forecast {
   maxlead = ## forecast_maxlead
   maxback = ## forecast_maxback
}

## x11regression { variables = ( td ) }

x11 {
   mode = ## x11_mode
   save = (## x11_output)
   appendbcst = no
   appendfcst = no
}

