/**
 * Escape special regex characters in a string.
 * Use this BEFORE passing user input into $regex or new RegExp().
 * @param {string} str - Raw user input
 * @returns {string} - Escaped string safe for regex
 */
const escapeRegex = (str) => {
    if (!str || typeof str !== 'string') return '';
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
};

module.exports = escapeRegex;
