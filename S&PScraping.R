# Make sure data.table is installed
if(!'data.table' %in% installed.packages()[,1]) install.packages('data.table')

# Function to fetch google stock data
google <- function(sym, current = TRUE, sy = 2005, sm = 1, sd = 1, ey, em, ed)
{
    
    if(current){
        system_time <- as.character(Sys.time())
        ey <- as.numeric(substr(system_time, start = 1, stop = 4))
        em <- as.numeric(substr(system_time, start = 6, stop = 7))
        ed <- as.numeric(substr(system_time, start = 9, stop = 10))
    }
    
    require(data.table)
    
    google_out = tryCatch(
        suppressWarnings(
            fread(paste0("http://www.google.com/finance/historical",
                         "?q=", sym,
                         "&startdate=", paste(sm, sd, sy, sep = "+"),
                         "&enddate=", paste(em, ed, ey, sep = "+"),
                         "&output=csv"), sep = ",")),
        error = function(e) NULL
    )
    
    if(!is.null(google_out)){
        names(google_out)[1] = "Date"
    }
    
    return(google_out)
}

# Load list of symbols
SYM <- as.character( read.csv('SnPSymbols.csv', 
                              stringsAsFactors = FALSE, header = FALSE)[,1] )
#need to make sure the Symbols file and the R file are in the same directory
#user setwd command if required to achieve this

# Hold stock data and vector of invalid requests
DATA <- list()
INVALID <- c()

# Attempt to fetch each symbol
for(sym in SYM){
    google_out <- google(sym)
    Sys.sleep(3)
    if(!is.null(google_out)) {
        DATA[[sym]] <- google_out #get the stock prices
        DATA[[sym]]$Company <- sym #and tag them with the stock ticker
    } else {
        INVALID <- c(INVALID, sym)
    }
}

# Overwrite with only valid symbols
SYM <- names(DATA)

# Remove iteration variables
rm(google_out, sym)

#these are print commands that be ignored if not required
cat("Successfully download", length(DATA), "symbols.")
cat(length(INVALID), "invalid symbols requested.\n", paste(INVALID, collapse = "\n\t"))
cat("We now have a list of data frames of each symbol.")
cat("e.g. access MMM price history with DATA[['MMM']]")

#create a long csv file with all the stock data
lapply(DATA, function(x) write.table(data.frame(x), 'mytestlist.csv'  , append= T, sep=',' ))
