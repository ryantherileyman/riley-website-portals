package ca.rileyman.common.general.dao;

import java.util.Date;

/**
 * Provides data access for general calendar information.
 */
public interface CalendarDao {
	
	/**
	 * Retrieves the current date and time.
	 * 
	 * @return Current date and time
	 */
	Date getCurrentDatetime();
	
}
