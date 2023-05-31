defmodule Ukio.Apartments.Booking do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Ukio.Repo
  alias Ukio.Apartments.Booking
  alias Ukio.Apartments.Apartment

  schema "bookings" do
    belongs_to(:apartment, Apartment)

    field :check_in, :date
    field :check_out, :date
    field :deposit, :integer
    field :monthly_rent, :integer
    field :utilities, :integer

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:check_in, :check_out, :apartment_id, :monthly_rent, :deposit, :utilities])
    |> validate_required([
      :check_in,
      :check_out,
      :apartment_id,
      :monthly_rent,
      :deposit,
      :utilities
    ])
  end

  def must_be_avaiable_dates(%{changes: changes}=changeset) do
    if not must_be_avaiable_apartment(changes[:apartment_id], changes[:check_in]) and not must_be_avaiable_apartment(changes[:apartment_id], changes[:check_out]) do
      changeset
    else
      false
    end
  end

  def must_be_avaiable_apartment(apartment_id, date) do
    query = from b in Booking,
      where: b.apartment_id == ^apartment_id and b.check_in <= ^date and b.check_out >= ^date
    Repo.exists?(query)
  end
end
