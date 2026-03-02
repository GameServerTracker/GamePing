//
//  ServerFormView.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import StoreKit
import SwiftData
import SwiftUI

struct ServerFormView: View {

    let server: GameServer?

    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) var colorScheme

    @Environment(\.reviewManager) private var reviewManager
    @Environment(\.requestReview) private var requestReview

    @State var viewModel: ServerFormViewModel
    @FocusState private var focusedTextField: FormTextField?

    @State private var sheetDetent: PresentationDetent = .height(200)
    @Binding var isShowing: Bool

    init(server: GameServer?, isShowing: Binding<Bool>) {
        self.server = server
        self._isShowing = isShowing
        _viewModel = State(
            wrappedValue: ServerFormViewModel(server: server)
        )
    }

    enum FormTextField: Hashable {
        case hostname, name
    }

    var body: some View {
        NavigationView {
            Form {
                HStack(alignment: .center) {
                    Spacer()
                    Button {
                        viewModel.isIconEditedSheetPresented.toggle()
                    } label: {
                        ServerIconDefault(
                            iconImage: Image(viewModel.iconName),
                            gradientColors: [viewModel.bgColor],
                            foregroundColor: viewModel.fgColor,
                        )
                        .frame(width: 102, height: 102)
                    }.buttonStyle(.plain)
                    Spacer()
                }.listRowBackground(Color.clear).padding(.bottom, -6)
                Section {
                    addressField
                    nameField
                    typeField
                    portField
                    ignoreIconField
                } header: {
                    Text("Server Info")
                } footer: {
                    if viewModel.serverType == .fivem {
                        Text(
                            "Following iOS constraints, This server type requires to uses an external API to fetch the server status.\ngamerservertracker.io"
                        )
                    }
                }
            }.navigationTitle(
                Text(server == nil ? "Add a server" : "Edit server")
            )
            .sheet(isPresented: $viewModel.isIconEditedSheetPresented) { iconSheet }
            .toolbar {
                ToolbarItem(placement: .primaryAction) { saveToolbarButton }
                ToolbarItem(placement: .cancellationAction) { cancelToolbarButton }
            }
        }
    }

    @ViewBuilder
    private var nameField: some View {
        HStack {
            Image(systemName: "tag.fill")
                .resizable()
                .frame(width: 20, height: 20)
            TextField(
                "Name - My Server",
                text: $viewModel.serverName
            )
            .disableAutocorrection(true)
            .focused($focusedTextField, equals: FormTextField.name)
            .onSubmit { focusedTextField = nil }
            .submitLabel(.continue)
        }
    }
    
    @ViewBuilder
    private var addressField: some View {
        HStack {
            Image(systemName: "server.rack")
                .resizable()
                .frame(width: 20, height: 20)
            TextField(
                viewModel.serverType == .fivemctx ? "CTX Code - abc123" : "Hostname - myserver.net",
                text: $viewModel.serverAddress
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
            .focused(
                $focusedTextField,
                equals: FormTextField.hostname
            )
            .onSubmit {
                let addressSplit = viewModel.serverAddress.split(
                    separator: ":"
                )
                if addressSplit.count > 1 {
                    viewModel.serverPort = Int(addressSplit[1])
                    viewModel.serverAddress = String(
                        addressSplit[0]
                    )
                }
                if viewModel.serverName.isEmpty {
                    viewModel.serverName =
                        (addressSplit.count > 1)
                        ? String(addressSplit[0])
                        : viewModel.serverAddress
                }
                focusedTextField = .name
            }
            .onChange(of: focusedTextField) { _, newFocus in
                if newFocus != .hostname {
                    let addressSplit = viewModel.serverAddress
                        .split(separator: ":")
                    if addressSplit.count > 1 {
                        viewModel.serverPort = Int(addressSplit[1])
                        viewModel.serverAddress = String(
                            addressSplit[0]
                        )
                    }
                }
            }
            .toolbar { ToolbarItem(placement: .keyboard) { keyboardToolbar(focusedTextField) } }
            .submitLabel(.next)
        }
    }
    
    @ViewBuilder
    private var typeField: some View {
        HStack {
            Image(systemName: "gamecontroller.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Picker("Type", selection: $viewModel.serverType) {
                Text("Automatic").tag(GameServerType.auto)
                Text("Minecraft Java Edition").tag(
                    GameServerType.minecraft
                )
                Text("Minecraft Bedrock Edition").tag(
                    GameServerType.bedrock
                )
                Text("Source (CS,TF2,GMod,...)").tag(
                    GameServerType.source
                )
                Text("FiveM / RedM").tag(GameServerType.fivem)
                Text("FiveM CTX Code").tag(GameServerType.fivemctx)
            }
        }
    }
    
    @ViewBuilder
    private var portField: some View {
        if ![GameServerType.fivemctx]
            .contains(viewModel.serverType)
        {
            HStack {
                Image(systemName: "number")
                    .resizable()
                    .frame(width: 20, height: 20)
                TextField(
                    "Port (Optional)",
                    value: $viewModel.serverPort,
                    format: .number
                )
                .keyboardType(.numberPad)
            }
        }
    }
    
    @ViewBuilder
    private var ignoreIconField: some View {
        if [GameServerType.fivem, GameServerType.fivemctx, GameServerType.minecraft]
            .contains(viewModel.serverType)
        {
            HStack {
                Image(systemName: "photo")
                    .frame(width: 20, height: 20)
                Toggle(
                    "Ignore Server Icon",
                    isOn: $viewModel.serverIconIgnore
                )
            }
        }
    }
    
    @ViewBuilder
    private var iconSheet: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    Grid(horizontalSpacing: 20) {
                        GridRow {
                            ForEach(
                                customServerIcons.indices,
                                id: \.self
                            ) { idx in
                                Button {
                                    viewModel.iconName =
                                        customServerIcons[idx].imageName
                                } label: {
                                    ServerIconDefault(
                                        iconImage: Image(
                                            customServerIcons[idx]
                                                .imageName
                                        ),
                                        gradientColors: [
                                            viewModel.bgColor
                                        ],
                                        foregroundColor: viewModel
                                            .fgColor
                                    )
                                    .frame(width: 72, height: 72)
                                }
                            }
                        }
                        GridRow {
                            ForEach(
                                customServerIcons.indices,
                                id: \.self
                            ) { idx in
                                if customServerIcons[idx].imageName
                                    == viewModel.iconName
                                {
                                    Text(customServerIcons[idx].name)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.thinMaterial)
                                        .clipShape(Capsule())
                                } else {
                                    Text(customServerIcons[idx].name)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }.padding([.leading], 16)

            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Personalize Icon")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        ColorPicker(
                            "",
                            selection: $viewModel.bgColor,
                            supportsOpacity: false
                        ).labelsHidden()
                        ColorPicker(
                            "",
                            selection: $viewModel.fgColor,
                            supportsOpacity: false
                        ).labelsHidden()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(10)
        }
        .presentationDetents(
            [.height(200), .large],
            selection: $sheetDetent
        )
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder
    private func keyboardToolbar (_ focusedField: FormTextField?) -> some View {
        if focusedField == .hostname {
            HStack {
                Button {
                    if let paste = UIPasteboard.general
                        .string
                    {
                        viewModel.serverAddress = paste
                    }
                } label: {
                    Image(
                        systemName:
                            "document.on.clipboard.fill"
                    )
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(
                        colorScheme == .dark
                            ? .white : .black
                    )
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var saveToolbarButton: some View {
        if #available(iOS 26, *) {
            Button {
                handleSave()
            } label: {
                Image(systemName: "checkmark")
            }.disabled(!viewModel.isValid).tint(
                viewModel.isValid ? .green : .primary
            )
        } else {
            Button("Save") { handleSave() }
                .disabled(!viewModel.isValid)
        }
    }
    
    @ViewBuilder
    private var cancelToolbarButton: some View {
        Button {
            isShowing = false
        } label: {
            if #available(iOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Text("Cancel")
            }
        }
    }
    
    private func handleSave() {
        let saveAction: ServerSaveAction = viewModel.save(
            context: context
        )
        var reviewCriteria: ReviewCriteria? = nil
        isShowing = false

        switch saveAction {
        case .add:
            reviewCriteria = .addServer
        case .edit:
            reviewCriteria = .editServer
        }
        reviewManager.requestReviewIfNeeded(
            criteria: reviewCriteria!,
            requestReview: {
                requestReview()
            }
        )
    }
}

#Preview {
    ServerFormView(server: nil, isShowing: .constant(true))
        .modelContainer(for: GameServer.self, inMemory: true)
}
