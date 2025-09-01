defmodule IagocavalcanteWeb.Photos do
  use Phoenix.Component

  def photos(assigns) do
    assigns = assign(assigns, :photos, [
      %{img: "/images/home-1.jpeg", rotate: "rotate-2"},
      %{img: "/images/home-2.jpeg", rotate: "-rotate-2"},
      %{img: "/images/home-3.jpeg", rotate: "rotate-2"},
      %{img: "/images/home-4.jpeg", rotate: "-rotate-2"},
      %{img: "/images/home-5.jpeg", rotate: "rotate-2"}
    ])

    ~H"""
    <div
      :for={photo <- @photos}
      class={"relative aspect-[9/10] w-44 flex-none overflow-hidden rounded-xl bg-zinc-100 dark:bg-zinc-800 sm:w-72 sm:rounded-2xl #{photo.rotate}"}
    >
      <img
        alt=""
        sizes="(min-width: 640px) 18rem, 11rem"
        srcset={photo.img}
        src={photo.img}
        decoding="async"
        data-nimg="1"
        class="absolute inset-0 h-full w-full object-cover"
        loading="lazy"
        style="color: transparent;"
        width="3744"
        height="5616"
      />
    </div>
    """
  end
end
