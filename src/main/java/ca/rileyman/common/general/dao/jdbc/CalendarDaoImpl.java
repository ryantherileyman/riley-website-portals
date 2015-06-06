package ca.rileyman.common.general.dao.jdbc;

import java.util.Date;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import ca.rileyman.common.general.dao.CalendarDao;

/**
 * JDBC-based implementation of the general calendar data access object.
 */
@Repository
public class CalendarDaoImpl
implements CalendarDao
{
	
	private JdbcTemplate jdbcTemplate;
	
	@SuppressWarnings("javadoc")
	@Autowired
	public CalendarDaoImpl(DataSource dataSource) {
		this.jdbcTemplate = new JdbcTemplate(dataSource);
	}
	
	@Transactional(propagation=Propagation.SUPPORTS, readOnly=true)
	public Date getCurrentDatetime() {
		Date result = jdbcTemplate.queryForObject("SELECT NOW()", Date.class);
		return result;
	}
	
}
