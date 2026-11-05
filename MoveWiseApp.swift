import SwiftUI

import Charts

import Combine

import UIKit



// MARK: - App entry point

// If your project already has an @main App struct, keep only ONE @main declaration.

// Replace the contents of your main Swift file with this complete file.



@main

struct CommutePlannerApp: App {

    @StateObject private var planner = PlannerViewModel()



    var body: some Scene {

        WindowGroup {

            RootView()

                .environmentObject(planner)

                .preferredColorScheme(.light)

        }

    }

}



// MARK: - Root navigation



struct RootView: View {

    @State private var selection = 0



    var body: some View {

        TabView(selection: $selection) {

            PlannerView()

                .tabItem { Label("Plan", systemImage: "map.fill") }

                .tag(0)

            CompareView()

                .tabItem { Label("Compare", systemImage: "chart.bar.fill") }

                .tag(1)

            FutureView()

                .tabItem { Label("2040", systemImage: "sparkles") }

                .tag(2)

            InsightsView()

                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }

                .tag(3)

        }

        .tint(Brand.coral)

    }

}



// MARK: - Brand and shared styling



enum Brand {

    static let name = "MoveWise"

    static let tagline = "Make every commute count"

    static let developer = "A smarter way to move"

    static let coral = Color(red: 0.96, green: 0.36, blue: 0.32)

    static let teal = Color(red: 0.10, green: 0.64, blue: 0.60)

    static let indigo = Color(red: 0.27, green: 0.31, blue: 0.68)

    static let saffron = Color(red: 0.96, green: 0.62, blue: 0.20)

    static let gradient = LinearGradient(

        colors: [coral, Color(red: 0.91, green: 0.25, blue: 0.48)],

        startPoint: .topLeading, endPoint: .bottomTrailing

    )

    static let coolGradient = LinearGradient(

        colors: [indigo, teal],

        startPoint: .topLeading, endPoint: .bottomTrailing

    )

}



extension Font {

    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {

        .system(size: size, weight: weight, design: .rounded)

    }

}



extension View {

    func appCard() -> some View {

        self

            .padding(16)

            .frame(maxWidth: .infinity, alignment: .leading)

            .background(Color.white)

            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            .shadow(color: .black.opacity(0.055), radius: 12, x: 0, y: 5)

    }

}



struct Screen<Content: View>: View {

    let title: String

    let subtitle: String

    @ViewBuilder let content: Content



    var body: some View {

        NavigationStack {

            ScrollView(showsIndicators: false) {

                VStack(spacing: 14) {

                    content

                }

                .padding(.horizontal, 16)

                .padding(.top, 12)

                .padding(.bottom, 28)

            }

            .background(Color(red: 0.96, green: 0.965, blue: 0.98))

            .navigationTitle(title)

            .navigationBarTitleDisplayMode(.large)

            .toolbar {

                ToolbarItem(placement: .principal) {

                    VStack(spacing: 1) {

                        Text(title).font(.rounded(17, .bold))

                        Text(subtitle).font(.rounded(10, .medium)).foregroundStyle(.secondary)

                    }

                }

            }

        }

    }

}



struct SectionTitle: View {

    let title: String

    let icon: String



    init(_ title: String, icon: String) {

        self.title = title

        self.icon = icon

    }



    var body: some View {

        Label(title, systemImage: icon)

            .font(.rounded(17, .bold))

            .foregroundStyle(Color.primary)

    }

}



struct Chip: View {

    let title: String

    let selected: Bool

    let action: () -> Void



    var body: some View {

        Button(action: action) {

            Text(title)

                .font(.rounded(13, .semibold))

                .padding(.horizontal, 13)

                .padding(.vertical, 9)

                .foregroundStyle(selected ? Color.white : Color.primary)

                .background(selected ? AnyShapeStyle(Brand.gradient) : AnyShapeStyle(Color(.secondarySystemBackground)))

                .clipShape(Capsule())

        }

        .buttonStyle(.plain)

    }

}



struct BestBadge: View {

    var body: some View {

        Label("BEST MATCH", systemImage: "crown.fill")

            .font(.rounded(10, .heavy))

            .padding(.horizontal, 9)

            .padding(.vertical, 6)

            .background(Color.white.opacity(0.2))

            .clipShape(Capsule())

    }

}



struct DisclaimerNote: View {

    var body: some View {

        HStack(alignment: .top, spacing: 8) {

            Image(systemName: "info.circle.fill").foregroundStyle(Brand.indigo)

            Text("Estimates are illustrative and vary by route, traffic, fares, weather and local infrastructure. Check live services before travelling.")

                .font(.rounded(11, .medium))

                .foregroundStyle(.secondary)

        }

        .padding(.horizontal, 4)

    }

}



struct BouncyStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {

        configuration.label

            .scaleEffect(configuration.isPressed ? 0.97 : 1)

            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)

    }

}



enum Haptics {

    static func soft() {

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

    }

    static func selection() {

        UISelectionFeedbackGenerator().selectionChanged()

    }

    static func tap() {

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

    }

}



enum Fmt {

    static func rupees(_ value: Double) -> String { "₹\(Int(value.rounded()))" }

    static func minutes(_ value: Double) -> String {

        let total = max(0, Int(value.rounded()))

        let hours = total / 60

        let mins = total % 60

        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins) min"

    }

    static func co2(_ value: Double) -> String { "\(value.formatted(.number.precision(.fractionLength(1)))) kg" }

}



// MARK: - Domain models



enum Mode: String, CaseIterable, Identifiable {

    case metro, bus, car, bike, walk, cab

    var id: String { rawValue }



    var name: String {

        switch self {

        case .metro: "Metro"

        case .bus: "Bus"

        case .car: "Private car"

        case .bike: "Bicycle"

        case .walk: "Walking"

        case .cab: "Cab"

        }

    }

    var subtitle: String {

        switch self {

        case .metro: "Fast urban rail"

        case .bus: "Public road transport"

        case .car: "Personal vehicle"

        case .bike: "Active mobility"

        case .walk: "Zero-emission travel"

        case .cab: "On-demand ride"

        }

    }

    var icon: String {

        switch self {

        case .metro: "tram.fill"

        case .bus: "bus.fill"

        case .car: "car.fill"

        case .bike: "bicycle"

        case .walk: "figure.walk"

        case .cab: "car.side.fill"

        }

    }

    var color: Color {

        switch self {

        case .metro: Brand.indigo

        case .bus: Brand.teal

        case .car: Brand.coral

        case .bike: Brand.saffron

        case .walk: .green

        case .cab: .purple

        }

    }

}



struct City: Identifiable, Equatable {

    let id: String

    let name: String

    let metroCoverage: Double

}



enum DataStore {

    static let cities: [City] = [

        City(id: "delhi", name: "New Delhi", metroCoverage: 0.82),

        City(id: "mumbai", name: "Mumbai", metroCoverage: 0.68),

        City(id: "bengaluru", name: "Bengaluru", metroCoverage: 0.48),

        City(id: "ahmedabad", name: "Ahmedabad", metroCoverage: 0.42),

        City(id: "hyderabad", name: "Hyderabad", metroCoverage: 0.55),

        City(id: "pune", name: "Pune", metroCoverage: 0.30),

        City(id: "chennai", name: "Chennai", metroCoverage: 0.50),

        City(id: "kolkata", name: "Kolkata", metroCoverage: 0.62)

    ]



    static func improvements(_ mode: Mode) -> [Improvement] {

        switch mode {

        case .metro:

            [Improvement(icon: "arrow.left.arrow.right", title: "Network expansion", detail: "More stations and interchange connections."), Improvement(icon: "bolt.fill", title: "Cleaner operations", detail: "Greater use of renewable electricity and efficient trains.")]

        case .bus:

            [Improvement(icon: "bus.fill", title: "Electric bus fleets", detail: "More low-emission buses and improved frequency."), Improvement(icon: "clock.fill", title: "Bus priority", detail: "Dedicated lanes and signal priority where feasible.")]

        case .car:

            [Improvement(icon: "battery.100", title: "Electric vehicles", detail: "A larger share of journeys may use electric cars."), Improvement(icon: "car.2.fill", title: "Shared trips", detail: "Carpooling can reduce the number of vehicles on roads.")]

        case .bike:

            [Improvement(icon: "bicycle", title: "Protected lanes", detail: "Safer connected cycling routes."), Improvement(icon: "parkingsign.circle.fill", title: "Secure parking", detail: "More bicycle parking at stations and workplaces.")]

        case .walk:

            [Improvement(icon: "figure.walk", title: "Walkable streets", detail: "Continuous footpaths, shade and safer crossings."), Improvement(icon: "tree.fill", title: "Cooler routes", detail: "More trees and public-space improvements.")]

        case .cab:

            [Improvement(icon: "bolt.car.fill", title: "Electric cabs", detail: "A greater share of app-based rides may be electric."), Improvement(icon: "arrow.triangle.branch", title: "Smarter matching", detail: "Better ride matching may reduce empty kilometres.")]

        }

    }



    static func insight(_ mode: Mode) -> Insight {

        switch mode {

        case .metro:

            Insight(headline: "A strong option for longer urban trips", bestFor: "Longer trips on connected corridors", facts: ["Metro trains can move many passengers using relatively little road space.", "Actual journey time includes walking, waiting and interchange time."], tips: ["Check station access at both ends.", "Use a transit card or app where available."])

        case .bus:

            Insight(headline: "Flexible public transport coverage", bestFor: "Affordable trips across a wide area", facts: ["Buses can serve neighbourhoods beyond rail corridors.", "Traffic and service frequency affect journey time."], tips: ["Check the route and direction before boarding.", "Allow extra time during peak traffic."])

        case .car:

            Insight(headline: "Door-to-door convenience with higher road impact", bestFor: "Trips with multiple stops or limited transit", facts: ["A car's per-person impact depends heavily on occupancy.", "Parking and congestion can add significant time."], tips: ["Share the ride when possible.", "Combine errands into one trip."])

        case .bike:

            Insight(headline: "Active travel for short and medium trips", bestFor: "Short trips with safe cycling routes", facts: ["Cycling adds physical activity to daily travel.", "Protected infrastructure can make cycling more comfortable."], tips: ["Wear a helmet where appropriate.", "Use lights and visible clothing."])

        case .walk:

            Insight(headline: "Simple, healthy and emission-free", bestFor: "Short trips and first/last-mile connections", facts: ["Walking has no direct tailpipe emissions.", "Footpath quality, shade and crossings matter."], tips: ["Choose well-lit pedestrian routes.", "Stay hydrated in hot weather."])

        case .cab:

            Insight(headline: "Convenient point-to-point travel", bestFor: "Occasional trips or journeys with luggage", facts: ["Vehicle occupancy and traffic affect per-person emissions.", "Pickup and drop-off time can vary."], tips: ["Compare the fare before booking.", "Consider sharing a ride if practical."])

        }

    }

}



struct Improvement: Identifiable {

    let id = UUID()

    let icon: String

    let title: String

    let detail: String

}



struct Insight {

    let headline: String

    let bestFor: String

    let facts: [String]

    let tips: [String]

}



enum Priority: String, CaseIterable, Identifiable {

    case balanced, cost, speed, green

    var id: String { rawValue }

    var title: String {

        switch self {

        case .balanced: "Balanced"

        case .cost: "Lowest cost"

        case .speed: "Fastest"

        case .green: "Eco-friendly"

        }

    }

    var subtitle: String {

        switch self {

        case .balanced: "A bit of everything"

        case .cost: "Save money"

        case .speed: "Save time"

        case .green: "Lower emissions"

        }

    }

    var icon: String {

        switch self {

        case .balanced: "scale.3d"

        case .cost: "indianrupeesign.circle.fill"

        case .speed: "bolt.fill"

        case .green: "leaf.fill"

        }

    }

    var weights: Weights {

        switch self {

        case .balanced: Weights(cost: 5, time: 5, green: 5, health: 4, comfort: 4, safety: 5)

        case .cost: Weights(cost: 10, time: 3, green: 3, health: 2, comfort: 2, safety: 4)

        case .speed: Weights(cost: 3, time: 10, green: 2, health: 1, comfort: 4, safety: 4)

        case .green: Weights(cost: 4, time: 3, green: 10, health: 8, comfort: 2, safety: 4)

        }

    }

}



enum Era: String, CaseIterable, Identifiable {

    case today, future

    var id: String { rawValue }

    var title: String { self == .today ? "Today" : "2040" }

}



enum Metric: String, CaseIterable, Identifiable {

    case cost = "Cost"

    case time = "Time"

    case co2 = "CO₂"

    case comfort = "Comfort"

    var id: String { rawValue }

    var unit: String {

        switch self {

        case .cost: "₹ per trip"

        case .time: "Minutes"

        case .co2: "kg CO₂"

        case .comfort: "Score / 10"

        }

    }

    var lowerIsBetter: Bool { self != .comfort }

    func value(_ result: ModeResult) -> Double {

        switch self {

        case .cost: result.cost

        case .time: result.minutes

        case .co2: result.co2

        case .comfort: result.comfort

        }

    }

    func short(_ value: Double) -> String {

        self == .cost ? "₹\(Int(value.rounded()))" : "\(Int(value.rounded()))"

    }

}



struct Weights {

    var cost: Double

    var time: Double

    var green: Double

    var health: Double

    var comfort: Double

    var safety: Double

}



struct ModeResult: Identifiable {

    var id: Mode { mode }

    let mode: Mode

    let cost: Double

    let minutes: Double

    let co2: Double

    let calories: Double

    let comfort: Double

    let safety: Double

    let reliability: Double

    let accessibility: Double

    let practical: Bool

    var score: Double

}



// MARK: - Planner calculations



final class PlannerViewModel: ObservableObject {

    @Published var city: City = DataStore.cities[0]

    @Published var distance: Double = 8

    @Published var priority: Priority = .balanced

    @Published var era: Era = .today

    @Published var metric: Metric = .cost

    @Published var weights: Weights = Priority.balanced.weights

    @Published var vehicle: PrivateVehicle = .petrolCar

    @Published var savingsMode: Mode = .metro

    @Published var commuteDays: Double = 5



    var results: [ModeResult] { Mode.allCases.map { result($0, era: era) } }

    var ranked: [ModeResult] { results.sorted { $0.score > $1.score } }

    var best: ModeResult { ranked.first ?? result(.metro, era: era) }

    var chartSignature: String { "\(city.id)-\(Int(distance))-\(era.rawValue)-\(metric.rawValue)" }



    func reason(for result: ModeResult) -> String {

        switch priority {

        case .cost: "A strong choice for keeping your travel costs down"

        case .speed: "A strong choice for reducing travel time"

        case .green: "A strong choice for reducing your travel footprint"

        case .balanced: "The strongest overall match for your priorities"

        }

    }



    func result(_ mode: Mode, era: Era) -> ModeResult {

        let future = era == .future

        let km = max(1.0, distance)

        let cityFactor = city.id == "delhi" ? 0.94 : 1.0



        let baseCost: Double

        let speed: Double

        let emission: Double

        let calories: Double

        let comfort: Double

        let safety: Double

        let reliability: Double

        let access: Double



        switch mode {

        case .metro:

            baseCost = 12 + km * 1.7; speed = 2.0; emission = 0.035; calories = 12

            comfort = 8.0; safety = 8.0; reliability = 8.5; access = city.metroCoverage * 10

        case .bus:

            baseCost = 8 + km * 1.1; speed = 1.15; emission = 0.075; calories = 10

            comfort = 6.2; safety = 6.8; reliability = 6.3; access = 7.8

        case .car:

            baseCost = 35 + km * 7.0; speed = 1.45; emission = 0.19; calories = 5

            comfort = 8.5; safety = 6.8; reliability = 5.5; access = 9.0

        case .bike:

            baseCost = 1 + km * 0.15; speed = 0.27; emission = 0.0; calories = 28

            comfort = 5.8; safety = 5.6; reliability = 7.0; access = 6.0

        case .walk:

            baseCost = 0; speed = 0.083; emission = 0.0; calories = 48

            comfort = 5.5; safety = 6.0; reliability = 8.0; access = 8.0

        case .cab:

            baseCost = 45 + km * 12.0; speed = 1.4; emission = 0.17; calories = 4

            comfort = 8.8; safety = 6.7; reliability = 6.0; access = 9.5

        }



        let futureCostFactor = future ? (mode == .car || mode == .cab ? 0.88 : 0.92) : 1.0

        let futureSpeedFactor = future ? 1.18 : 1.0

        let futureEmissionFactor = future ? 0.65 : 1.0

        let cost = baseCost * cityFactor * futureCostFactor

        let minutes = (km / speed) * cityFactor / futureSpeedFactor + (mode == .metro ? 8 : mode == .bus ? 6 : 2)

        let co2 = km * emission * (future ? futureEmissionFactor : 1)

        let isPractical = mode != .walk || km <= 5



        let w = weights

        let costScore = max(0.0, 10.0 - cost / max(1.0, km) / 3.0)

        let timeScore = max(0.0, 10.0 - minutes / max(1.0, km) / 3.0)

        let greenScore = max(0.0, 10.0 - co2 * 2.0)

        let practicalPenalty: Double = isPractical ? 0.0 : 18.0

        let totalWeight = max(1.0, w.cost + w.time + w.green + w.health + w.comfort + w.safety)

        let rawScore = (costScore * w.cost + timeScore * w.time + greenScore * w.green +

                        min(10.0, calories / 5.0) * w.health + comfort * w.comfort + safety * w.safety) / totalWeight * 10

        let score = min(100.0, max(0.0, rawScore - practicalPenalty))



        return ModeResult(mode: mode, cost: cost, minutes: minutes, co2: co2,

                          calories: calories * km, comfort: min(10.0, comfort + (future ? 0.8 : 0.0)),

                          safety: min(10.0, safety + (future ? 1.0 : 0.0)),

                          reliability: min(10.0, reliability + (future ? 1.0 : 0.0)),

                          accessibility: min(10.0, access + (future ? 1.0 : 0.0)),

                          practical: isPractical, score: score)

    }



    var savings: Savings {

        let days = commuteDays * 50

        let trips = days * 2

        let distancePerYear = distance * trips

        let alternative = result(savingsMode, era: .today)

        let privateCostPerKm = vehicle.costPerKm

        let privateCO2PerKm = vehicle.co2PerKm

        let money = distancePerYear * (privateCostPerKm - (alternative.cost / max(1.0, distance)))

        let co2 = distancePerYear * max(0.0, privateCO2PerKm - (alternative.co2 / max(1.0, distance)))

        return Savings(money: money, calories: alternative.calories * trips,

                       co2Kg: co2, trees: co2 / 21, trips: trips)

    }



    func eraPoints(_ metric: Metric) -> [EraPoint] {

        Mode.allCases.flatMap { mode in

            [Era.today, Era.future].map { era in

                EraPoint(mode: mode.name, era: era.title, value: metric.value(result(mode, era: era)))

            }

        }

    }



    var qualityPoints: [QualityPoint] {

        results.flatMap { r in

            [

                QualityPoint(mode: r.mode.name, metric: "Comfort", value: r.comfort),

                QualityPoint(mode: r.mode.name, metric: "Safety", value: r.safety),

                QualityPoint(mode: r.mode.name, metric: "Reliability", value: r.reliability),

                QualityPoint(mode: r.mode.name, metric: "Access", value: r.accessibility)

            ]

        }

    }

}



enum PrivateVehicle: String, CaseIterable, Identifiable {

    case petrolCar, dieselCar, scooter

    var id: String { rawValue }

    var name: String {

        switch self {

        case .petrolCar: "Petrol car"

        case .dieselCar: "Diesel car"

        case .scooter: "Petrol scooter"

        }

    }

    var costPerKm: Double {

        switch self {

        case .petrolCar: 8.5

        case .dieselCar: 7.0

        case .scooter: 2.5

        }

    }

    var co2PerKm: Double {

        switch self {

        case .petrolCar: 0.19

        case .dieselCar: 0.17

        case .scooter: 0.075

        }

    }

}



struct Savings {

    let money: Double

    let calories: Double

    let co2Kg: Double

    let trees: Double

    let trips: Double

}



struct EraPoint: Identifiable {

    var id: String { "\(mode)-\(era)" }

    let mode: String

    let era: String

    let value: Double

}



struct QualityPoint: Identifiable {

    var id: String { "\(mode)-\(metric)" }

    let mode: String

    let metric: String

    let value: Double

}



// MARK: - Splash



struct SplashView: View {

    @State private var appear = false

    @State private var pulse = false



    var body: some View {

        ZStack {

            Brand.coolGradient.ignoresSafeArea()

            Circle()

                .stroke(Color.white.opacity(0.22), lineWidth: 2)

                .frame(width: 240, height: 240)

                .scaleEffect(pulse ? 1.9 : 0.8)

                .opacity(pulse ? 0 : 1)

            Circle()

                .stroke(Color.white.opacity(0.18), lineWidth: 2)

                .frame(width: 240, height: 240)

                .scaleEffect(pulse ? 1.4 : 0.6)

                .opacity(pulse ? 0 : 1)

            VStack(spacing: 18) {

                Spacer()

                Image(systemName: "leaf.circle.fill")

                    .font(.system(size: 110))

                    .foregroundStyle(.white)

                    .scaleEffect(appear ? 1 : 0.4)

                    .rotationEffect(.degrees(appear ? 0 : -25))

                    .opacity(appear ? 1 : 0)

                VStack(spacing: 6) {

                    Text(Brand.name).font(.rounded(36, .heavy)).foregroundStyle(.white)

                    Text(Brand.tagline).font(.rounded(17, .medium)).foregroundStyle(.white.opacity(0.85))

                }

                .opacity(appear ? 1 : 0)

                .offset(y: appear ? 0 : 24)

                Spacer()

                Text(Brand.developer)

                    .font(.rounded(14, .medium))

                    .foregroundStyle(.white.opacity(0.85))

                    .padding(.bottom, 30)

                    .opacity(appear ? 1 : 0)

            }

        }

        .onAppear {

            Haptics.soft()

            withAnimation(.spring(response: 0.9, dampingFraction: 0.65)) { appear = true }

            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) { pulse = true }

        }

    }

}



// MARK: - Planner



struct PlannerView: View {

    @EnvironmentObject private var vm: PlannerViewModel



    private var distanceBinding: Binding<Double> {

        Binding(get: { vm.distance }, set: {

            if Int($0) != Int(vm.distance) { Haptics.selection() }

            vm.distance = $0

        })

    }



    var body: some View {

        Screen(title: Brand.name, subtitle: "Plan your commute") {

            cityCard

            distanceCard

            priorityCard

            bestCard

            glanceCard

            SavingsCard()

            DisclaimerNote()

        }

    }



    private var cityCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            SectionTitle("Choose your city", icon: "building.2.fill")

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 8) {

                    ForEach(DataStore.cities) { city in

                        Chip(title: city.name, selected: vm.city == city) {

                            withAnimation(.spring()) { vm.city = city }

                        }

                    }

                }

            }

            Text("Estimated metro coverage in \(vm.city.name): \(Int(vm.city.metroCoverage * 100))%")

                .font(.rounded(12, .medium)).foregroundStyle(.secondary)

        }

        .appCard()

    }



    private var distanceCard: some View {

        VStack(alignment: .leading, spacing: 10) {

            SectionTitle("Trip distance", icon: "ruler.fill")

            HStack(alignment: .firstTextBaseline) {

                Text("\(Int(vm.distance))")

                    .font(.rounded(44, .heavy))

                    .foregroundStyle(Brand.gradient)

                    .contentTransition(.numericText())

                Text("km one way").font(.rounded(16, .semibold)).foregroundStyle(.secondary)

            }

            Slider(value: distanceBinding, in: 1...40, step: 1).tint(Brand.coral)

        }

        .appCard()

    }



    private var priorityCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            SectionTitle("What matters most?", icon: "target")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {

                ForEach(Priority.allCases) { p in

                    Button {

                        Haptics.tap()

                        withAnimation(.spring()) {

                            vm.priority = p

                            vm.weights = p.weights

                        }

                    } label: {

                        HStack(spacing: 9) {

                            Image(systemName: p.icon).font(.system(size: 19, weight: .bold)).frame(width: 25)

                            VStack(alignment: .leading, spacing: 2) {

                                Text(p.title).font(.rounded(14, .bold))

                                Text(p.subtitle).font(.rounded(10, .medium)).opacity(0.8)

                            }

                            Spacer(minLength: 0)

                        }

                        .padding(11)

                        .foregroundStyle(vm.priority == p ? Color.white : Color.primary)

                        .background(vm.priority == p ? AnyShapeStyle(Brand.gradient) : AnyShapeStyle(Color(.tertiarySystemFill)))

                        .clipShape(RoundedRectangle(cornerRadius: 15))

                    }

                    .buttonStyle(BouncyStyle())

                }

            }

        }

        .appCard()

    }



    private var bestCard: some View {

        let best = vm.best

        return VStack(alignment: .leading, spacing: 14) {

            HStack {

                BestBadge()

                Spacer()

                Text("\(vm.era.title) · \(vm.city.name)")

                    .font(.rounded(11, .semibold))

                    .padding(.horizontal, 9).padding(.vertical, 5)

                    .background(Capsule().fill(Color.white.opacity(0.2)))

            }

            HStack(spacing: 13) {

                Image(systemName: best.mode.icon)

                    .font(.system(size: 31, weight: .bold))

                    .frame(width: 60, height: 60)

                    .background(Circle().fill(Color.white.opacity(0.2)))

                VStack(alignment: .leading, spacing: 4) {

                    Text(best.mode.name).font(.rounded(28, .heavy))

                    Text(vm.reason(for: best)).font(.rounded(12, .medium)).opacity(0.9)

                }

            }

            HStack(spacing: 7) {

                statPill("indianrupeesign.circle.fill", Fmt.rupees(best.cost))

                statPill("clock.fill", Fmt.minutes(best.minutes))

                statPill("leaf.fill", Fmt.co2(best.co2))

            }

        }

        .foregroundStyle(.white)

        .padding(17)

        .frame(maxWidth: .infinity, alignment: .leading)

        .background(Brand.gradient)

        .clipShape(RoundedRectangle(cornerRadius: 24))

        .shadow(color: Brand.coral.opacity(0.25), radius: 12, x: 0, y: 6)

        .animation(.spring(), value: best.mode)

    }



    private func statPill(_ icon: String, _ text: String) -> some View {

        HStack(spacing: 4) {

            Image(systemName: icon)

            Text(text).lineLimit(1).minimumScaleFactor(0.7)

        }

        .font(.rounded(11, .bold))

        .padding(.horizontal, 8).padding(.vertical, 6)

        .background(Capsule().fill(Color.white.opacity(0.2)))

    }



    private var glanceCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            SectionTitle("At a glance", icon: "square.grid.2x2.fill")

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 10) {

                    ForEach(vm.results) { result in

                        VStack(alignment: .leading, spacing: 6) {

                            Image(systemName: result.mode.icon)

                                .font(.system(size: 20, weight: .bold))

                                .foregroundStyle(result.mode.color)

                            Text(result.mode.name).font(.rounded(13, .bold))

                            Text(Fmt.rupees(result.cost)).font(.rounded(12, .semibold))

                            Text(Fmt.minutes(result.minutes)).font(.rounded(11, .medium)).foregroundStyle(.secondary)

                        }

                        .padding(11)

                        .frame(width: 108, alignment: .leading)

                        .background(result.mode.color.opacity(vm.best.mode == result.mode ? 0.20 : 0.08))

                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(vm.best.mode == result.mode ? result.mode.color : .clear, lineWidth: 2))

                        .clipShape(RoundedRectangle(cornerRadius: 15))

                    }

                }

            }

        }

        .appCard()

    }

}



// MARK: - Savings calculator



struct SavingsCard: View {

    @EnvironmentObject private var vm: PlannerViewModel



    var body: some View {

        let savings = vm.savings

        return VStack(alignment: .leading, spacing: 13) {

            SectionTitle("Savings calculator", icon: "leaf.circle.fill")

            Text("What if you switch from a private vehicle?")

                .font(.rounded(12, .medium)).foregroundStyle(.secondary)

            Picker("Private vehicle", selection: $vm.vehicle) {

                ForEach(PrivateVehicle.allCases) { vehicle in

                    Text(vehicle.name).tag(vehicle)

                }

            }

            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 8) {

                    ForEach(Mode.allCases) { mode in

                        Chip(title: mode.name, selected: vm.savingsMode == mode) {

                            withAnimation { vm.savingsMode = mode }

                        }

                    }

                }

            }

            VStack(alignment: .leading, spacing: 4) {

                Text("Commute days per week: \(Int(vm.commuteDays))")

                    .font(.rounded(13, .semibold))

                Slider(value: $vm.commuteDays, in: 1...7, step: 1).tint(Brand.teal)

            }

            HStack(spacing: 9) {

                SavingTile(icon: "indianrupeesign.circle.fill",

                           value: Fmt.rupees(savings.money),

                           title: savings.money >= 0 ? "Estimated saved per year" : "Estimated extra cost per year",

                           color: savings.money >= 0 ? .green : .red)

                SavingTile(icon: "flame.fill",

                           value: "\(Int(savings.calories.rounded())) kcal",

                           title: "Estimated calories per year",

                           color: .orange)

            }

            SavingTile(icon: "tree.fill",

                       value: savings.co2Kg > 0 ? "\(Int(savings.co2Kg.rounded())) kg CO₂ saved" : "No CO₂ saved",

                       title: savings.co2Kg > 0 ? "About \(Int(savings.trees.rounded())) tree-years at 21 kg per tree" : "This option does not reduce estimated CO₂",

                       color: Brand.teal)

            Text("Estimate based on \(Int(savings.trips)) one-way trips per year, at \(Int(vm.distance)) km each way.")

                .font(.rounded(11, .medium)).foregroundStyle(.secondary)

        }

        .appCard()

    }

}



struct SavingTile: View {

    let icon: String

    let value: String

    let title: String

    let color: Color



    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Image(systemName: icon).foregroundStyle(color)

            Text(value).font(.rounded(18, .bold)).lineLimit(2).minimumScaleFactor(0.7)

            Text(title).font(.rounded(10, .medium)).foregroundStyle(.secondary)

                .fixedSize(horizontal: false, vertical: true)

        }

        .padding(11)

        .frame(maxWidth: .infinity, alignment: .leading)

        .background(color.opacity(0.10))

        .clipShape(RoundedRectangle(cornerRadius: 15))

    }

}



// MARK: - Compare



struct CompareView: View {

    @EnvironmentObject private var vm: PlannerViewModel



    var body: some View {

        Screen(title: "Compare modes", subtitle: "\(Int(vm.distance)) km · \(vm.city.name)") {

            EraPicker(era: $vm.era)

            metricChartCard

            rankingCard

            weightsCard

            qualityCard

            ForEach(vm.results) { result in ModeDetailCard(result: result) }

            DisclaimerNote()

        }

    }



    private var metricChartCard: some View {

        VStack(alignment: .leading, spacing: 12) {

            SectionTitle("Side by side", icon: "chart.bar.fill")

            Picker("Metric", selection: $vm.metric) {

                ForEach(Metric.allCases) { metric in Text(metric.rawValue).tag(metric) }

            }

            .pickerStyle(.segmented)

            Chart(vm.results) { result in

                BarMark(x: .value("Mode", result.mode.name),

                        y: .value(vm.metric.rawValue, vm.metric.value(result)))

                    .foregroundStyle(result.mode.color)

                    .cornerRadius(5)

                    .annotation(position: .top) {

                        Text(vm.metric.short(vm.metric.value(result)))

                            .font(.system(size: 9, weight: .semibold, design: .rounded))

                            .foregroundStyle(.secondary)

                    }

            }

            .frame(height: 220)

            .chartYAxisLabel(vm.metric.unit)

            Text(vm.metric.lowerIsBetter ? "Lower is better." : "Higher is better.")

                .font(.rounded(11, .medium)).foregroundStyle(.secondary)

        }

        .appCard()

    }



    private var rankingCard: some View {

        VStack(alignment: .leading, spacing: 13) {

            SectionTitle("Your ranking", icon: "trophy.fill")

            ForEach(Array(vm.ranked.enumerated()), id: \.element.mode) { index, result in

                RankRow(rank: index + 1, result: result, isBest: index == 0)

            }

        }

        .appCard()

    }



    private var weightsCard: some View {

        VStack(alignment: .leading, spacing: 11) {

            HStack {

                SectionTitle("Adjust your weights", icon: "slider.horizontal.3")

                Spacer()

                Button("Reset") {

                    Haptics.tap()

                    withAnimation { vm.weights = vm.priority.weights }

                }

                .font(.rounded(13, .semibold))

                .tint(Brand.coral)

            }

            Text("Drag to tell the ranking what matters to you.")

                .font(.rounded(11, .medium)).foregroundStyle(.secondary)

            WeightSlider(title: "Cost", icon: "indianrupeesign.circle.fill", value: $vm.weights.cost)

            WeightSlider(title: "Speed", icon: "bolt.fill", value: $vm.weights.time)

            WeightSlider(title: "Low CO₂", icon: "leaf.fill", value: $vm.weights.green)

            WeightSlider(title: "Health", icon: "heart.fill", value: $vm.weights.health)

            WeightSlider(title: "Comfort", icon: "sofa.fill", value: $vm.weights.comfort)

            WeightSlider(title: "Safety", icon: "shield.fill", value: $vm.weights.safety)

        }

        .appCard()

    }



    private var qualityCard: some View {

        VStack(alignment: .leading, spacing: 11) {

            SectionTitle("Comfort, safety, reliability, access", icon: "checkmark.seal.fill")

            Chart(vm.qualityPoints) { point in

                BarMark(x: .value("Mode", point.mode), y: .value("Score", point.value))

                    .foregroundStyle(by: .value("Metric", point.metric))

                    .position(by: .value("Metric", point.metric))

            }

            .chartYScale(domain: 0.0...10.0)

            .frame(height: 240)

            .chartLegend(position: .bottom)

            Text("Scores out of 10 (higher is better).")

                .font(.rounded(11, .medium)).foregroundStyle(.secondary)

        }

        .appCard()

    }

}



struct EraPicker: View {

    @Binding var era: Era

    var body: some View {

        Picker("Era", selection: $era) {

            ForEach(Era.allCases) { era in Text(era.title).tag(era) }

        }

        .pickerStyle(.segmented)

        .padding(5)

        .background(Color.white)

        .clipShape(RoundedRectangle(cornerRadius: 13))

    }

}



struct WeightSlider: View {

    let title: String

    let icon: String

    @Binding var value: Double



    var body: some View {

        HStack(spacing: 9) {

            Image(systemName: icon).foregroundStyle(Brand.gradient).frame(width: 22)

            Text(title).font(.rounded(12, .semibold)).frame(width: 65, alignment: .leading)

            Slider(value: $value, in: 0...10, step: 1).tint(Brand.coral)

            Text("\(Int(value))").font(.rounded(12, .bold)).frame(width: 20, alignment: .trailing)

        }

    }

}



struct RankRow: View {

    let rank: Int

    let result: ModeResult

    let isBest: Bool



    var body: some View {

        HStack(spacing: 10) {

            Text("\(rank)")

                .font(.rounded(14, .bold))

                .frame(width: 27, height: 27)

                .background(isBest ? AnyShapeStyle(Brand.gradient) : AnyShapeStyle(Color(.tertiarySystemFill)))

                .foregroundStyle(isBest ? Color.white : Color.secondary)

                .clipShape(Circle())

            Image(systemName: result.mode.icon)

                .font(.system(size: 18, weight: .bold))

                .foregroundStyle(result.mode.color)

                .frame(width: 25)

            VStack(alignment: .leading, spacing: 5) {

                HStack {

                    Text(result.mode.name).font(.rounded(14, .bold))

                    if isBest { BestBadge() }

                    Spacer()

                    Text("\(Int(result.score.rounded()))")

                        .font(.rounded(14, .bold))

                }

                GeometryReader { geometry in

                    ZStack(alignment: .leading) {

                        Capsule().fill(Color(.tertiarySystemFill))

                        Capsule().fill(result.mode.color)

                            .frame(width: max(CGFloat(5), geometry.size.width * CGFloat(result.score / 100)))

                    }

                }

                .frame(height: 7)

                if !result.practical {

                    Text("Long trip for this mode: score reduced")

                        .font(.rounded(10, .medium)).foregroundStyle(.orange)

                }

            }

        }

    }

}



struct StatCell: View {

    let title: String

    let value: String

    var body: some View {

        VStack(spacing: 3) {

            Text(value).font(.rounded(12, .bold)).lineLimit(1).minimumScaleFactor(0.65)

            Text(title).font(.rounded(9, .medium)).foregroundStyle(.secondary)

        }

        .frame(maxWidth: .infinity)

        .padding(.vertical, 8)

        .background(Color(.tertiarySystemFill))

        .clipShape(RoundedRectangle(cornerRadius: 9))

    }

}



struct ModeDetailCard: View {

    let result: ModeResult



    var body: some View {

        VStack(alignment: .leading, spacing: 11) {

            HStack(spacing: 9) {

                Image(systemName: result.mode.icon)

                    .font(.system(size: 17, weight: .bold))

                    .foregroundStyle(.white)

                    .frame(width: 36, height: 36)

                    .background(Circle().fill(result.mode.color))

                VStack(alignment: .leading, spacing: 1) {

                    Text(result.mode.name).font(.rounded(16, .bold))

                    Text(result.mode.subtitle).font(.rounded(10, .medium)).foregroundStyle(.secondary)

                }

                Spacer()

            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 4), spacing: 7) {

                StatCell(title: "Cost", value: Fmt.rupees(result.cost))

                StatCell(title: "Time", value: Fmt.minutes(result.minutes))

                StatCell(title: "CO₂", value: Fmt.co2(result.co2))

                StatCell(title: "Calories", value: "\(Int(result.calories.rounded()))")

                StatCell(title: "Comfort", value: String(format: "%.1f", result.comfort))

                StatCell(title: "Safety", value: String(format: "%.1f", result.safety))

                StatCell(title: "Reliability", value: String(format: "%.1f", result.reliability))

                StatCell(title: "Access", value: String(format: "%.1f", result.accessibility))

            }

        }

        .appCard()

    }

}



// MARK: - Future 2040



struct FutureView: View {

    @EnvironmentObject private var vm: PlannerViewModel



    var body: some View {

        Screen(title: "Future 2040", subtitle: "Today vs 2040 · \(vm.city.name)") {

            heroCard

            EraPicker(era: $vm.era)

            eraChartCard

            ForEach(Mode.allCases) { mode in ModeFutureCard(mode: mode) }

            DisclaimerNote()

        }

    }



    private var heroCard: some View {

        VStack(alignment: .leading, spacing: 8) {

            Label("India's cities by 2040", systemImage: "sparkles")

                .font(.rounded(19, .heavy))

            Text("Electric buses, bigger metro networks, protected bike lanes, tap-to-pay cards and shared-mobility apps could make many journeys faster, cleaner and safer. These are illustrative scenarios, not guaranteed forecasts.")

                .font(.rounded(13, .medium)).opacity(0.92)

        }

        .foregroundStyle(.white)

        .padding(17)

        .frame(maxWidth: .infinity, alignment: .leading)

        .background(Brand.coolGradient)

        .clipShape(RoundedRectangle(cornerRadius: 22))

    }



    private var eraChartCard: some View {

        VStack(alignment: .leading, spacing: 11) {

            SectionTitle("Today vs 2040", icon: "arrow.left.arrow.right.circle.fill")

            Picker("Metric", selection: $vm.metric) {

                ForEach(Metric.allCases) { metric in Text(metric.rawValue).tag(metric) }

            }

            .pickerStyle(.segmented)

            Chart(vm.eraPoints(vm.metric)) { point in

                BarMark(x: .value("Mode", point.mode), y: .value(vm.metric.rawValue, point.value))

                    .foregroundStyle(by: .value("Era", point.era))

                    .position(by: .value("Era", point.era))

                    .cornerRadius(4)

            }

            .chartYAxisLabel(vm.metric.unit)

            .chartLegend(position: .bottom)

            .frame(height: 230)

        }

        .appCard()

    }

}



struct ChangeChip: View {

    let title: String

    let value: String

    let change: Double?

    let lowerIsBetter: Bool



    private var isGood: Bool {

        guard let change else { return false }

        return lowerIsBetter ? change < 0 : change > 0

    }



    var body: some View {

        VStack(spacing: 3) {

            Text(title).font(.rounded(9, .medium)).foregroundStyle(.secondary)

            Text(value).font(.rounded(12, .bold)).lineLimit(1).minimumScaleFactor(0.6)

            if let change, abs(change) >= 0.5 {

                Text(String(format: "%+.0f%%", change))

                    .font(.rounded(9, .bold))

                    .foregroundStyle(isGood ? Color.green : Color.red)

            } else {

                Text(" ").font(.rounded(9, .bold))

            }

        }

        .frame(maxWidth: .infinity)

        .padding(.vertical, 7)

        .background(Color(.tertiarySystemFill))

        .clipShape(RoundedRectangle(cornerRadius: 9))

    }

}



struct ModeFutureCard: View {

    @EnvironmentObject private var vm: PlannerViewModel

    let mode: Mode



    private func percentage(_ new: Double, _ old: Double) -> Double? {

        old > 0.0001 ? (new - old) / old * 100 : nil

    }



    var body: some View {

        let today = vm.result(mode, era: .today)

        let future = vm.result(mode, era: .future)

        let isFuture = vm.era == .future

        let shown = isFuture ? future : today



        VStack(alignment: .leading, spacing: 11) {

            HStack(spacing: 9) {

                Image(systemName: mode.icon)

                    .font(.system(size: 17, weight: .bold))

                    .foregroundStyle(.white)

                    .frame(width: 36, height: 36)

                    .background(Circle().fill(mode.color))

                VStack(alignment: .leading, spacing: 1) {

                    Text(mode.name).font(.rounded(16, .bold))

                    Text(isFuture ? "Illustrative 2040 scenario" : "Illustrative current estimate")

                        .font(.rounded(10, .medium)).foregroundStyle(.secondary)

                }

                Spacer()

            }

            HStack(spacing: 7) {

                ChangeChip(title: "Time", value: Fmt.minutes(shown.minutes),

                           change: isFuture ? percentage(future.minutes, today.minutes) : nil, lowerIsBetter: true)

                ChangeChip(title: "Cost", value: Fmt.rupees(shown.cost),

                           change: isFuture ? percentage(future.cost, today.cost) : nil, lowerIsBetter: true)

                ChangeChip(title: "CO₂", value: Fmt.co2(shown.co2),

                           change: isFuture ? percentage(future.co2, today.co2) : nil, lowerIsBetter: true)

                ChangeChip(title: "Comfort", value: String(format: "%.1f", shown.comfort),

                           change: isFuture ? percentage(future.comfort, today.comfort) : nil, lowerIsBetter: false)

            }

            Divider()

            Text(isFuture ? "Potential changes" : "Possible upgrades")

                .font(.rounded(12, .bold)).foregroundStyle(.secondary)

            ForEach(DataStore.improvements(mode)) { improvement in

                HStack(alignment: .top, spacing: 9) {

                    Image(systemName: improvement.icon)

                        .font(.system(size: 13, weight: .bold))

                        .foregroundStyle(Brand.gradient)

                        .frame(width: 22, height: 22)

                    VStack(alignment: .leading, spacing: 2) {

                        Text(improvement.title).font(.rounded(13, .bold))

                        Text(improvement.detail).font(.rounded(12)).foregroundStyle(.secondary)

                    }

                }

            }

            .opacity(isFuture ? 1 : 0.6)

        }

        .appCard()

    }

}



// MARK: - Insights



struct InsightsView: View {

    var body: some View {

        Screen(title: "Insights", subtitle: "Facts and tips for every mode") {

            ForEach(Mode.allCases) { mode in InsightCard(mode: mode) }

            DisclaimerNote()

        }

    }

}



struct InsightCard: View {

    let mode: Mode

    @State private var isOpen = false



    var body: some View {

        let info = DataStore.insight(mode)

        VStack(alignment: .leading, spacing: 11) {

            Button {

                Haptics.tap()

                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isOpen.toggle() }

            } label: {

                HStack(spacing: 10) {

                    Image(systemName: mode.icon)

                        .font(.system(size: 17, weight: .bold))

                        .foregroundStyle(.white)

                        .frame(width: 40, height: 40)

                        .background(Circle().fill(mode.color))

                    VStack(alignment: .leading, spacing: 2) {

                        Text(mode.name).font(.rounded(16, .bold)).foregroundStyle(.primary)

                        Text(info.headline).font(.rounded(11, .medium)).foregroundStyle(.secondary)

                            .multilineTextAlignment(.leading)

                    }

                    Spacer()

                    Image(systemName: "chevron.down")

                        .font(.system(size: 12, weight: .bold))

                        .foregroundStyle(.secondary)

                        .rotationEffect(.degrees(isOpen ? 180 : 0))

                }

                .contentShape(Rectangle())

            }

            .buttonStyle(.plain)



            if isOpen {

                VStack(alignment: .leading, spacing: 10) {

                    Label("Best for: \(info.bestFor)", systemImage: "scope")

                        .font(.rounded(12, .semibold)).foregroundStyle(mode.color)

                    Text("Did you know?").font(.rounded(12, .bold)).foregroundStyle(.secondary)

                    ForEach(info.facts.indices, id: \.self) { index in

                        HStack(alignment: .top, spacing: 8) {

                            Image(systemName: "lightbulb.fill")

                                .foregroundStyle(Brand.saffron)

                            Text(info.facts[index])

                                .fixedSize(horizontal: false, vertical: true)

                        }

                        .font(.rounded(12))

                    }

                    Text("Tips").font(.rounded(12, .bold)).foregroundStyle(.secondary)

                    ForEach(info.tips.indices, id: \.self) { index in

                        HStack(alignment: .top, spacing: 8) {

                            Image(systemName: "checkmark.seal.fill")

                                .foregroundStyle(Brand.teal)

                            Text(info.tips[index])

                                .fixedSize(horizontal: false, vertical: true)

                        }

                        .font(.rounded(12))

                    }

                }

                .transition(.opacity.combined(with: .move(edge: .top)))

            }

        }

        .appCard()

    }

}



struct InsightLabelStyle: LabelStyle {

    let iconColor: Color

    func makeBody(configuration: Configuration) -> some View {

        HStack(alignment: .top, spacing: 8) {

            configuration.icon.foregroundStyle(iconColor)

            configuration.title.fixedSize(horizontal: false, vertical: true)

        }

    }

}



// MARK: - Preview



#Preview {

    RootView()

        .environmentObject(PlannerViewModel())
