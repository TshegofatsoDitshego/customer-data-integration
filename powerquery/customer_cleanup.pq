let
    // Step 1: Load source data
    Source = Csv.Document(
        Web.Contents("YOUR_BLOB_STORAGE_URL/customers.csv"),
        [Delimiter=",", Columns=7, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    
    // Step 2: Promote headers
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    
    // Step 3: Change data types (initial)
    ChangedType = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"customer_id", type text},
            {"first_name", type text},
            {"last_name", type text},
            {"email", type text},
            {"phone", type text},
            {"signup_date", type text},  // Keep as text initially to handle multiple formats
            {"country", type text}
        }
    ),
    
    // Step 4: Trim whitespace from all text columns
    TrimmedText = Table.TransformColumns(
        ChangedType,
        {
            {"customer_id", Text.Trim},
            {"first_name", Text.Trim},
            {"last_name", Text.Trim},
            {"email", Text.Trim},
            {"phone", Text.Trim},
            {"country", Text.Trim}
        }
    ),
    
    // Step 5: Standardize email (lowercase)
    LowercaseEmail = Table.TransformColumns(
        TrimmedText,
        {{"email", Text.Lower}}
    ),
    
    // Step 6: Filter out records with missing emails
    FilteredEmails = Table.SelectRows(
        LowercaseEmail, 
        each [email] <> null and [email] <> ""
    ),
    
    // Step 7: Standardize phone numbers
    // Remove all spaces, dashes, and parentheses first
    CleanPhone = Table.TransformColumns(
        FilteredEmails,
        {{"phone", each if _ <> null then 
            Text.Replace(Text.Replace(Text.Replace(_, " ", ""), "-", ""), "(", "")
        else null}}
    ),
    
    // Add +27 if phone starts with 0
    StandardizePhone = Table.AddColumn(
        CleanPhone,
        "phone_standardized",
        each if [phone] <> null then
            if Text.Start([phone], 1) = "0" then
                "+27" & Text.Range([phone], 1)
            else if Text.Start([phone], 3) = "+27" then
                [phone]
            else
                [phone]
        else null
    ),
    
    // Step 8: Standardize country names
    StandardizeCountry = Table.AddColumn(
        StandardizePhone,
        "country_standardized",
        each if [country] = "ZA" or [country] = "RSA" then
            "South Africa"
        else
            [country]
    ),
    
    // Step 9: Parse dates (handle multiple formats)
    ParseDate = Table.AddColumn(
        StandardizeCountry,
        "signup_date_parsed",
        each try 
            // Try ISO format first (YYYY-MM-DD)
            Date.From([signup_date])
        otherwise try
            // Try DD/MM/YYYY format
            Date.FromText([signup_date], [Format="dd/MM/yyyy"])
        otherwise
            // If all fails, return null
            null
    ),
    
    // Step 10: Add data quality flags
    AddQualityFlags = Table.AddColumn(
        ParseDate,
        "data_quality_issues",
        each Text.Combine(
            {
                if [phone] = null or [phone] = "" then "MISSING_PHONE; " else "",
                if [signup_date_parsed] = null then "INVALID_DATE; " else "",
                if [signup_date_parsed] > DateTime.Date(DateTime.LocalNow()) then "FUTURE_DATE; " else ""
            },
            ""
        )
    ),
    
    // Step 11: Remove duplicates based on email (keep first occurrence)
    RemovedDuplicates = Table.Distinct(AddQualityFlags, {"email"}),
    
    // Step 12: Select and rename final columns
    SelectColumns = Table.SelectColumns(
        RemovedDuplicates,
        {
            "customer_id",
            "first_name",
            "last_name", 
            "email",
            "phone_standardized",
            "country_standardized",
            "signup_date_parsed",
            "data_quality_issues"
        }
    ),
    
    RenameColumns = Table.RenameColumns(
        SelectColumns,
        {
            {"phone_standardized", "phone"},
            {"country_standardized", "country"},
            {"signup_date_parsed", "signup_date"}
        }
    ),
    
    // Step 13: Final type conversion
    FinalTypes = Table.TransformColumnTypes(
        RenameColumns,
        {
            {"customer_id", type text},
            {"first_name", type text},
            {"last_name", type text},
            {"email", type text},
            {"phone", type text},
            {"country", type text},
            {"signup_date", type date},
            {"data_quality_issues", type text}
        }
    )
in
    FinalTypes