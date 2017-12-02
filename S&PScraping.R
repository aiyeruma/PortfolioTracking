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

# Test it
google_data = google('GOOGL')

# Load list of symbols
SYM <- as.character( read.csv('D:/MS-BAIM/Web Data/SnPSymbols.csv', 
                              stringsAsFactors = FALSE, header = FALSE)[,1] )
# Hold stock data and vector of invalid requests
DATA <- list()
INVALID <- c()

# Attempt to fetch each symbol
for(sym in SYM){
    google_out <- google(sym)
    Sys.sleep(3)
    if(!is.null(google_out)) {
        DATA[[sym]] <- google_out
        DATA[[sym]]$Company <- sym
    } else {
        INVALID <- c(INVALID, sym)
    }
}

# Overwrite with only valid symbols
SYM <- names(DATA)

# Remove iteration variables
rm(google_out, sym)

cat("Successfully download", length(DATA), "symbols.")
cat(length(INVALID), "invalid symbols requested.\n", paste(INVALID, collapse = "\n\t"))
cat("We now have a list of data frames of each symbol.")
cat("e.g. access MMM price history with DATA[['MMM']]")

#for (i in (1:length(SYM))){
#    DATA[[SYM[i]]]$Company <- SYM[i]
#}

lapply(DATA, function(x) write.table(data.frame(x), 'mytestlist.csv'  , append= T, sep=',' ))


#SYM = SYM[1:10]

#SYM <- as.character( read.csv('D:/MS-BAIM/Web Data/http://trading.chrisconlan.com/SPstocks_current.csv', 
#                              stringsAsFactors = FALSE, header = FALSE)[,1] )


