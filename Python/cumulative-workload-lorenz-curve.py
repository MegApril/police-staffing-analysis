# Colors
COLOR_Lorenz = "#38808c"
COLOR_Equality = "#465360"
COLOR_Shade = "#38808c"
COLOR_Point = "#f2b749"


# cutoff for lower 90% of calls
mask_90 = df_sorted["cumul_calls"] <= 0.90

plt.figure(figsize=(8,6))

# Lorenz curve
plt.plot(
    df_sorted["cumul_calls"],
    df_sorted["cumul_labor"],
    label="Lorenz Curve",
    color=COLOR_Lorenz,
    linewidth=2.5
)

# Equality line
plt.plot(
    [0, 1],
    [0, 1],
    linestyle="--",
    label="Perfect Equality",
    color=COLOR_Equality,
    linewidth=1.5
)

# Shading
plt.fill_between(
    df_sorted.loc[mask_90, "cumul_calls"],
    df_sorted.loc[mask_90, "cumul_labor"],
    color=COLOR_Shade,
    alpha=0.25
)

# 90% point
idx_90 = np.abs(df_sorted["cumul_calls"] - 0.90).idxmin()
x_90 = df_sorted.loc[idx_90, "cumul_calls"]
y_90 = df_sorted.loc[idx_90, "cumul_labor"]

plt.scatter(
    x_90,
    y_90,
    color=COLOR_Point,
    s=80,
    zorder=5
)

plt.annotate(
    "Bottom 90% of calls\n≈ {:.1%} of labor".format(y_90),
    (x_90, y_90),
    textcoords="offset points",
    xytext=(-95, 5)
)

plt.xlim(0,1)
plt.ylim(0,1)

plt.gca().xaxis.set_major_formatter(PercentFormatter(1))
plt.gca().yaxis.set_major_formatter(PercentFormatter(1))

plt.xlabel("Cumulative Share of Calls")
plt.ylabel("Cumulative Share of Labor Time")
plt.title("Workload Concentration for Calls for Service")
plt.legend()

plt.tight_layout()
plt.show()
