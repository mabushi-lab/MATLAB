function T = loadPriceData(csvPath)
%LOADPRICEDATA Read a wide-format price CSV into a sorted table.
%   T = LOADPRICEDATA(CSVPATH) reads a CSV with a 'Date' column plus one
%   column per ticker (closing prices), and returns it as a table sorted
%   ascending by date with Date converted to a proper datetime column.
%
%   Example:
%       T = loadPriceData('data/sample_prices.csv');
%       plot(T.Date, T.AAPL)

    if nargin < 1 || ~(ischar(csvPath) || isstring(csvPath))
        error('loadPriceData:badInput', 'csvPath must be a file path string.');
    end
    if ~isfile(csvPath)
        error('loadPriceData:notFound', 'File not found: %s', csvPath);
    end

    T = readtable(csvPath, 'TextType', 'string');

    if ~ismember('Date', T.Properties.VariableNames)
        error('loadPriceData:missingDate', 'CSV must contain a Date column.');
    end

    if ~isdatetime(T.Date)
        T.Date = datetime(T.Date, 'InputFormat', 'yyyy-MM-dd');
    end

    T = sortrows(T, 'Date');
end
