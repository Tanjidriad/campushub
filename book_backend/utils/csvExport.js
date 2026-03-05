/**
 * Convert an array of objects to CSV string.
 * @param {Array<Object>} data - Array of flat objects
 * @param {Array<string>} [columns] - Column headers (defaults to all keys from first object)
 * @returns {string} CSV string
 */
const toCSV = (data, columns) => {
    if (!data || data.length === 0) return '';

    const cols = columns || Object.keys(data[0]);

    // Header row
    const header = cols.map((col) => `"${col}"`).join(',');

    // Data rows
    const rows = data.map((row) =>
        cols
            .map((col) => {
                let val = row[col];
                if (val === null || val === undefined) val = '';
                if (val instanceof Date) val = val.toISOString();
                if (typeof val === 'object') val = JSON.stringify(val);
                // Escape double quotes and wrap in quotes
                return `"${String(val).replace(/"/g, '""')}"`;
            })
            .join(',')
    );

    return [header, ...rows].join('\n');
};

/**
 * Send CSV response with proper headers for browser download.
 * @param {Object} res - Express response object
 * @param {string} csv - CSV string
 * @param {string} filename - Download filename
 */
const sendCSV = (res, csv, filename) => {
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.send(csv);
};

module.exports = { toCSV, sendCSV };
