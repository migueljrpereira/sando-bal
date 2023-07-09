using Microsoft.EntityFrameworkCore;

namespace api.sandwich.net.Models;

public partial class SandwichContext : DbContext
{
    public SandwichContext()
    {
    }

    public SandwichContext(DbContextOptions<SandwichContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Sandwich> Sandwiches { get; set; }

    public virtual DbSet<Sandwichdescription> Sandwichdescriptions { get; set; }

    public virtual DbSet<Sandwichingredient> Sandwichingredients { get; set; }


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Sandwich>(entity =>
        {
            entity.HasKey(e => e.SandwichId).HasName("sandwich_pkey");

            entity.ToTable("sandwich");

            entity.Property(e => e.SandwichId).HasColumnName("sandwich_id");
            entity.Property(e => e.Designation)
                .HasMaxLength(255)
                .HasColumnName("designation");
            entity.Property(e => e.IsActive)
                .HasDefaultValueSql("true")
                .HasColumnName("is_active");
            entity.Property(e => e.SellingPrice).HasColumnName("selling_price");
        });

        modelBuilder.Entity<Sandwichdescription>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("sandwichdescriptions_pkey");

            entity.ToTable("sandwichdescriptions");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Content)
                .HasMaxLength(255)
                .HasColumnName("content");
            entity.Property(e => e.Language)
                .HasMaxLength(255)
                .HasColumnName("language");
            entity.Property(e => e.SandwichId).HasColumnName("sandwich_id");

            entity.HasOne(d => d.Sandwich).WithMany(p => p.Sandwichdescriptions)
                .HasForeignKey(d => d.SandwichId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("sandwichdescriptions_sandwich_id_fkey");
        });

        modelBuilder.Entity<Sandwichingredient>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("sandwichingredients_pkey");

            entity.ToTable("sandwichingredients");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.IngredientId).HasColumnName("ingredient_id");
            entity.Property(e => e.SandwichId).HasColumnName("sandwich_id");

            entity.HasOne(d => d.Sandwich).WithMany(p => p.Sandwichingredients)
                .HasForeignKey(d => d.SandwichId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("sandwichingredients_sandwich_id_fkey");

        });


        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
