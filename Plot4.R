# Plot4.R

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
  download.file(zipurl, destfile = "Dataset.zip", method = 'curl')
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

# Generate Plot 4
png(filename = "plot4.png", width = 480, height = 480, units = "px")
par(mfrow = c(2,2))

# Panel 1
with(powerData, plot(datetime, Global_active_power, xlab = "",
                     ylab = "Global Active Power (Kilowatts)", type = "l"))
# Panel 2
with(powerData, plot(datetime, Voltage, type = "l"))

# Panel 3
plot(powerData$datetime, powerData$Sub_metering_1, type = "l", col = "black",
     ylab = "Energy sub metering", xlab = "")
lines(powerData$datetime, powerData$Sub_metering_2, type = "l", col = "red")
lines(powerData$datetime, powerData$Sub_metering_3, type = "l", col = "blue")
legend("topright", legend = names(powerData)[7:9], bty = "n",
       lty = 1, col = c("black", "red", "blue"))

# Panel 4
with(powerData, plot(datetime, Global_reactive_power, type = "l"))

dev.off()


