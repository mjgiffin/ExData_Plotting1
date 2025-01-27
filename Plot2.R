# Plot2.R

packages = c("data.table","dplyr")

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

search()

# Download Data
zipurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
if (!file.exists("Dataset.zip")) {
  download.file(zipurl, destfile = "Dataset.zip", method = 'auto')
  # Extract data archive into data directory
  unzip(zipfile = "Dataset.zip")
}

# Read column names from file
powerColumns <- fread("household_power_consumption.txt", nrows = 0)

# Read data for specified Dates: Feb 1-2, 2007
# The `findstr` call is specific for Windows. If using on MacOS or Linux, 
# Please uncomment the other lines that call `grep`.

if (Sys.info()[1] == "Windows") {
  cmd1 <- paste('findstr /R /c:"^1/2/2007"')
  cmd2 <- paste('findstr /R /c:"^2/2/2007"')
} else {
  cmd1 <- paste("grep -E '^1/2/2007'")
  cmd2 <- paste("grep -E '^2/2/2007'")
}

# Read the data for Feb 1 and Feb 2
Feb1 <- fread(cmd = paste(cmd1, 'household_power_consumption.txt'))
Feb2 <- fread(cmd = paste(cmd2, 'household_power_consumption.txt'))

#Combine Data from days 1 & 2
powerData <- rbind(Feb1, Feb2)
names(powerData) <- names(powerColumns)

# Format Date and Time column
powerData$Date <- as.Date(powerData$Date, "%d/%m/%Y")
powerData <- mutate(powerData, datetime = as.POSIXct(paste(powerData$Date, powerData$Time), format = "%Y-%m-%d %H:%M:%S"))

# Generate Plot 2
png(filename = "plot2.png", width = 480, height = 480, units = "px")
with(powerData, plot(datetime, Global_active_power, xlab = "",
                     ylab = "Global Active Power (Kilowatts)", type = "l"))
dev.off()


