defmodule UkioWeb.BookingController do
  use UkioWeb, :controller

  import Ecto.Query

  alias Ukio.Repo
  alias Ukio.Apartments
  alias Ukio.Apartments.Booking
  alias Ukio.Bookings.Handlers.BookingCreator

  action_fallback UkioWeb.FallbackController

  @spec create(any, map) :: any
  def create(conn, %{"booking" => booking_params}) do
    if must_be_avaiable_dates?(booking_params) do
      with {:ok, %Booking{} = booking} <- BookingCreator.create(booking_params) do
        conn
        |> put_status(:created)
        |> render(:show, booking: booking)
      end
    else
      {:error, :unauthorized }
    end
  end

  def show(conn, %{"id" => id}) do
    booking = Apartments.get_booking!(id)
    render(conn, :show, booking: booking)
  end

  def must_be_avaiable_dates?(params) do
    must_be_avaiable_apartment?(params["apartment_id"], params["check_in"]) and must_be_avaiable_apartment?(params["apartment_id"], params["check_out"])
  end

  def must_be_avaiable_apartment?(apartment_id, date) do
    query = from b in Booking, where: b.apartment_id == ^apartment_id and b.check_in <= ^date and b.check_out >= ^date
    not Repo.exists?(query)
  end
end
