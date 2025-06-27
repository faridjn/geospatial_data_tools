// Author: Farid Javadnejad
// Institution: WSP Geomatics USA, Inc.
// Date: 2025-06-26
// 
// DESCRIPTION:
// This Office Script computes a 2D affine transformation using point coordinates stored in Excel.
// It reads coordinate pairs from two worksheets: "SOURCE" and "TARGET", each containing corresponding X and Y values.
// The script calculates the affine transformation coefficients and residuals, and writes the results to a "REPORT"
//
// USAGE:
// - Ensure the "SOURCE" and "TARGET" sheets each contain at least 3 matching point pairs.
// - Column B contains Y (Northing) and column C contains X (Easting) values, with one header row.
// - Run the script to generate or update a "REPORT" sheet with the calculated affine coefficients and residual statistics.
//
// EXAMPLE:
// SOURCE:
// PID    Northing (Y)    Easting (X)
// 1      488591.5266     644005.776
// 2      489757.2155     650091.4286
// 3      490392.2533     657073.5145
//
// TARGET:
// PID    Northing (Y)    Easting (X)
// 1      488507.6308     643999.1308
// 2      489696.2621     650080.3439
// 3      490357.6270     657059.9853
// 
// REPORT:
// Affine Transformation Coefficients	
// A0	1840.558024338450
// A1 -0.003771297073
// A2	0.999992889100
// B0 -2509.155695965060
// B1	0.999992882650
// B2	0.003771297443
//
// DISCLAIMER:
// This script was developed with the assistance of AI tools for coding, debugging, and validation.
// -----------------------------------------------------------------------------------------------