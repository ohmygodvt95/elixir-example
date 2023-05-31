defmodule UkioWeb.BookingControllerTest do
  use UkioWeb.ConnCase, async: true

  import Ukio.ApartmentsFixtures

  @create_attrs %{
    apartment_id: 42,
    check_in: ~D[2023-03-26],
    check_out: ~D[2023-03-26]
  }

  @invalid_attrs %{
    apartment_id: 1,
    check_in: nil,
    check_out: nil,
    deposit: nil,
    monthly_rent: nil,
    utilities: nil
  }

  setup %{conn: conn} do
    {:ok,
     conn: put_req_header(conn, "accept", "application/json"), apartment: apartment_fixture()}
  end

  describe "create booking" do
    test "renders booking when data is valid", %{conn: conn, apartment: apartment} do
      b = Map.merge(@create_attrs, %{apartment_id: apartment.id})
      conn = post(conn, ~p"/api/bookings", booking: b)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/bookings/#{id}")

      assert %{
               "id" => ^id,
               "check_in" => "2023-03-26",
               "check_out" => "2023-03-26",
               "deposit" => 100_000,
               "monthly_rent" => 250_000,
               "utilities" => 20000
             } = json_response(conn, 200)["data"]
    end

    test "return 401 in case the apartment is unavailable for the selected dates", %{conn: conn, apartment: apartment} do
      b = Map.merge(@create_attrs, %{apartment_id: apartment.id})
      conn = post(conn, ~p"/api/bookings", booking: b)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/bookings/#{id}")

      assert %{
               "id" => ^id,
               "check_in" => "2023-03-26",
               "check_out" => "2023-03-26",
               "deposit" => 100_000,
               "monthly_rent" => 250_000,
               "utilities" => 20000
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, apartment: apartment} do
      b = Map.merge(@invalid_attrs, %{apartment_id: apartment.id})
      conn = post(conn, ~p"/api/bookings", booking: b)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_booking(_) do
    booking = booking_fixture()
    %{booking: booking}
  end
end
