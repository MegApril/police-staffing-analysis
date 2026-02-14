# Find cutoff for lower 90% of calls
mask_90 = df_sorted["cum_calls"] <= 0.90

plt.figure()

# Plot Lorenz curve
plt.plot(df_sorted["cum_calls"], df_sorted["cum_labor"], label="Lorenz Curve")

# Plot ideal equality line
plt.plot([0,1], [0,1], linestyle="--", label="Perfect Equality")

# Shade area under Lorenz curve
plt.fill_between(
    df_sorted.loc[mask_90, "cum_calls"],
    df_sorted.loc[mask_90, "cum_labor"],
    alpha=0.3
)

# Mark 90% point
idx_90 = np.abs(df_sorted["cum_calls"] - 0.90).idxmin()
x_90 = df_sorted.loc[idx_90, "cum_calls"]
y_90 = df_sorted.loc[idx_90, "cum_labor"]

plt.scatter(x_90, y_90)

plt.annotate(
    "Bottom 90% of calls\n≈ {:.1%} of labor".format(y_90),
    (x_90, y_90),
    textcoords="offset points",
    xytext=(-95, 5)
)

plt.xlabel("Cumulative Share of Calls")
plt.ylabel("Cumulative Share of Labor Time")
plt.title("Workload Concentration for Calls for Service")
plt.legend()

plt.show()
