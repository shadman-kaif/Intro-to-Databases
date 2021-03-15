/* 
 * This code is provided solely for the personal and private use of students 
 * taking the CSC343H course at the University of Toronto. Copying for purposes 
 * other than this use is expressly prohibited. All forms of distribution of 
 * this code, including but not limited to public repositories on GitHub, 
 * GitLab, Bitbucket, or any other online platform, whether as given or with 
 * any changes, are expressly prohibited. 
*/ 

import java.sql.*;
import java.util.Date;
import java.util.Arrays;
import java.util.List;

public class Assignment2 {
   /////////
   // DO NOT MODIFY THE VARIABLE NAMES BELOW.
   
   // A connection to the database
   Connection connection;

   // Can use if you wish: seat letters
   List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to 'air_travel, public'.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
      // Implement this method!
      try {
         connection = DriverManager.getConnection(URL, username, password);
         String query = "SET SEARCH_PATH TO air_travel, public";
         PreparedStatement execStat = connection.prepareStatement(query);
         execStat.executeUpdate();
         return true;
      } catch (SQLException e) {
         return false;
      }
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      // Implement this method!
      try {
         connection.close();
         return true;
      } catch (SQLException e) {
         return false;
      }
   }
   
   /* ======================= Airline-related methods ======================= */

   /**
    * Attempts to book a flight for a passenger in a particular seat class. 
    * Does so by inserting a row into the Booking table.
    *
    * Read handout for information on how seats are booked.
    * Returns false if seat can't be booked, or if passenger or flight cannot be found.
    *
    * 
    * @param  passID     id of the passenger
    * @param  flightID   id of the flight
    * @param  seatClass  the class of the seat (economy, business, or first) 
    * @return            true if the booking was successful, false otherwise. 
    */
   public boolean bookSeat(int passID, int flightID, String seatClass) {
      // Implement this method!
      try {

         // Creates a table combining the booking, flight and plane relations
         // which we use to find the number of bookings that exist for a given flight and seat class
         PreparedStatement pStatement;
         ResultSet rs;
         String queryString =
            "SELECT * " + 
            "FROM BOOKING, flight, plane " + 
            "WHERE flight.plane = plane.tail_number and booking.flight_id = flight.id and seat_class = ?::seat_class and flight_id = ?;";
         pStatement = connection.prepareStatement(queryString);
         pStatement.setString(1, seatClass);
         pStatement.setInt(2, flightID);
         rs = pStatement.executeQuery();

        int count = 0;
        int econCap = 0;
        int busCap = 0;
        int firstCap = 0;

         int last_row = 1;
         char last_letter = 'A';
         String toomany = "no";

         while (rs.next()) {
            int id = rs.getInt("id");
            int pass_id = rs.getInt("pass_id");
            int flight_id = rs.getInt("flight_id");
            int price = rs.getInt("price");
            String seat_class = rs.getString("seat_class");
            int row = rs.getInt("row");
            String letter = rs.getString("letter");
            econCap = rs.getInt("capacity_economy");
            busCap = rs.getInt("capacity_business");
            firstCap = rs.getInt("capacity_first");
            
            if (letter != null) {
               count = count + 1;
               last_row = row;
               last_letter = letter.charAt(0);
            }
            else {
               
            }
         }
         
         int final_price = 0;
         PreparedStatement secondpStatement;
         ResultSet secondrs;
         String secondqueryString =
            "SELECT * " + 
            "FROM price " + 
            "WHERE flight_id = ?;";
            secondpStatement = connection.prepareStatement(secondqueryString);
            secondpStatement.setInt(1, flightID);
            secondrs = secondpStatement.executeQuery();
         
         while (secondrs.next()) {
           final_price = secondrs.getInt(seatClass);
         }


         if (toomany == "yes") {
         }

         else if (last_letter == 'A') {
            last_letter = 'B';
         }
         else if (last_letter == 'B') {
            last_letter = 'C';
         }
         else if (last_letter == 'C') {
            last_letter = 'D';
         }
         else if (last_letter == 'D') {
            last_letter = 'E';
         }
         else if (last_letter == 'E') {
            last_letter = 'F';
         }
         else if (last_letter == 'F') {
            last_row = last_row + 1;
            last_letter = 'A';
         }

         String letterinsert = String.valueOf(last_letter);


         PreparedStatement insertpStatement;
         int afterInsert;
         String toInsert = 
            "insert into " + 
            "BOOKING(pass_id, flight_id, datetime, price, seat_class, seat_row, seat_letter) " + 
            "values(?, ?, ?, ?, ?::seat_class, ?, ?)";
            insertpStatement = connection.prepareStatement(toInsert);
            insertpStatement.setInt(1, passID);
            insertpStatement.setInt(2, flightID);
            insertpStatement.setTimestamp(3, getCurrentTimeStamp());
            insertpStatement.setInt(4, final_price);
            insertpStatement.setString(5, seatClass);


         if (seatClass == "first") {
            if ((firstCap - count) > 0) {
               insertpStatement = connection.prepareStatement(toInsert);
               insertpStatement.setInt(1, passID);
               insertpStatement.setInt(2, flightID);
               insertpStatement.setTimestamp(3, getCurrentTimeStamp());
               insertpStatement.setInt(4, final_price);
               insertpStatement.setString(5, seatClass);
               insertpStatement.setInt(6, last_row);
               insertpStatement.setString(7, letterinsert);
               insertpStatement.executeUpdate();
            }
            else {
            }
         }
         else if (seatClass == "business") {
            if ((busCap - count) > 0) {
               insertpStatement = connection.prepareStatement(toInsert);
               insertpStatement.setInt(1, passID);
               insertpStatement.setInt(2, flightID);
               insertpStatement.setTimestamp(3, getCurrentTimeStamp());
               insertpStatement.setInt(4, final_price);
               insertpStatement.setString(5, seatClass);
               insertpStatement.setInt(6, last_row);
               insertpStatement.setString(7, letterinsert);
               insertpStatement.executeUpdate();
            }
            else {
            }
         }
         else if (seatClass == "economy") {
            if ((econCap - count) >= -10 && (econCap - count) <= 0) {
               insertpStatement = connection.prepareStatement(toInsert);
               insertpStatement.setInt(1, passID);
               insertpStatement.setInt(2, flightID);
               insertpStatement.setTimestamp(3, getCurrentTimeStamp());
               insertpStatement.setInt(4, final_price);
               insertpStatement.setString(5, seatClass);
               insertpStatement.setInt(6, 0);
               insertpStatement.setString(7, "");
               insertpStatement.executeUpdate();
            }
            else if ((econCap - count) > 0) {
               insertpStatement = connection.prepareStatement(toInsert);
               insertpStatement.setInt(1, passID);
               insertpStatement.setInt(2, flightID);
               insertpStatement.setTimestamp(3, getCurrentTimeStamp());
               insertpStatement.setInt(4, final_price);
               insertpStatement.setString(5, seatClass);
               insertpStatement.setInt(6, last_row);
               insertpStatement.setString(7, letterinsert);
               insertpStatement.executeUpdate();
            }
            else {
            }
         }
         else {
         }


         


         



         return true;
      } catch (SQLException e) {
         return false;
      }

   }

   /**
    * Attempts to upgrade overbooked economy passengers to business class
    * or first class (in that order until each seat class is filled).
    * Does so by altering the database records for the bookings such that the
    * seat and seat_class are updated if an upgrade can be processed.
    *
    * Upgrades should happen in order of earliest booking timestamp first.
    *
    * If economy passengers are left over without a seat (i.e. more than 10 overbooked passengers or not enough higher class seats), 
    * remove their bookings from the database.
    * 
    * @param  flightID  The flight to upgrade passengers in.
    * @return           the number of passengers upgraded, or -1 if an error occured.
    */
   public int upgrade(int flightID) {
      // Implement this method!
      return -1;
   }


   /* ----------------------- Helper functions below  ------------------------- */

    // A helpful function for adding a timestamp to new bookings.
    // Example of setting a timestamp in a PreparedStatement:
    // ps.setTimestamp(1, getCurrentTimeStamp());

    /**
    * Returns a SQL Timestamp object of the current time.
    * 
    * @return           Timestamp of current time.
    */
   private java.sql.Timestamp getCurrentTimeStamp() {
      java.util.Date now = new java.util.Date();
      return new java.sql.Timestamp(now.getTime());
   }

   // Add more helper functions below if desired.


  
  /* ----------------------- Main method below  ------------------------- */

   public static void main(String[] args) {

      // You can put testing code in here. It will not affect our autotester.
      System.out.println("Running the code!");

      try {
         Assignment2 a2 = new Assignment2();
         boolean conn = a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-khanab56", "khanab56", "");
         a2.bookSeat(1,5,"economy");
         conn = a2.disconnectDB();
      } catch(SQLException e) {
         System.err.println("error: ");
      }



   }

}
